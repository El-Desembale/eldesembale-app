// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../utils/design_tokens.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../cubit/home_cubit.dart';
import '../../../shared/widgets/primary_action_button.dart';

class WebPaymentView extends StatefulWidget {
  final String paymentUrl;
  final Future<void> Function() onSuccessfulPayment;
  final HomeCubit homeCubit;
  final String reference;
  final int amountInCents;

  /// Comisión Wompi exacta (suma de las cuotas pagadas); null para estimarla.
  final int? wompiFee;
  final String? loanId;
  final int? installmentNumber;
  final int? installmentsToPay;

  const WebPaymentView({
    super.key,
    required this.paymentUrl,
    required this.onSuccessfulPayment,
    required this.homeCubit,
    required this.reference,
    required this.amountInCents,
    this.wompiFee,
    this.loanId,
    this.installmentNumber,
    this.installmentsToPay,
  });

  @override
  State<WebPaymentView> createState() => _WebPaymentViewState();
}

class _WebPaymentViewState extends State<WebPaymentView> {
  late final WebViewController _controller;
  bool _procesingPayment = false;
  bool _showApprovedState = false;
  bool _hasExitedCheckout = false;
  bool _isLocked = false;
  Timer? _timer;
  String currentUrl = '';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _isLocked = true;

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            currentUrl = change.url ?? "";

            if (change.url != null &&
                    change.url!.contains('https://eldesembale.com.co/?') ||
                change.url!
                    .contains("https://transaction-redirect.wompi.co/")) {
              _hasExitedCheckout = true;
              _procesingPayment = true;
              setState(() {});
              final transaccionId = _extractIdFromUrl(change.url!);
              if (transaccionId.isEmpty) {
                return;
              } else {
                _timer = Timer.periodic(
                  const Duration(seconds: 5),
                  (t) async {
                    await getTransaccionStatus(transaccionId);
                  },
                );
              }
            }
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
    _controller = controller;

    super.initState();
  }

  Future<void> _handleClose() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      _controller.goBack();
      return;
    }
    if (!mounted) return;
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kBgScreenAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: kBorderFaint),
        ),
        title: const Text(
          '¿Cancelar el pago?',
          style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Si sales ahora, el pago no se completará.',
          style: TextStyle(color: kTextSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Seguir pagando', style: TextStyle(color: kTextSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFf87171)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if ((exit ?? false) && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showHeader = !_procesingPayment && !_showApprovedState;
    return PopScope(
      canPop: !_procesingPayment && !_showApprovedState,
      child: Scaffold(
        backgroundColor: kBgScreen,
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior fija, siempre visible
              if (showHeader)
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: kBgScreen,
                    border: Border(bottom: BorderSide(color: kBorderFaint)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _handleClose,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf87171).withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFf87171).withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_rounded, color: Color(0xFFf87171), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Salir',
                                style: TextStyle(
                                  color: Color(0xFFf87171),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Pago seguro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 72),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_hasExitedCheckout)
                      Container(color: const Color(0xFF0D1712)),
                    if (_procesingPayment)
                      _statusOverlay(
                        icon: Icons.lock_outline_rounded,
                        title: 'Validando tu pago',
                        message:
                            'Este proceso puede tardar unos segundos. Por favor no cierres la aplicación.',
                        footer: 'Pago protegido con Wompi',
                        showLoader: true,
                      ),
                    if (_showApprovedState)
                      _statusOverlay(
                        icon: Icons.check_rounded,
                        title: 'Tu pago ha sido aprobado',
                        message: 'Vamos a continuar con el proceso de tu solicitud.',
                        footer: 'Confirmación recibida correctamente',
                        showLoader: false,
                        action: PrimaryActionButton(
                          label: 'Entendido',
                          icon: Icons.check_rounded,
                          margin: EdgeInsets.zero,
                          onTap: () async {
                            setState(() => _showApprovedState = false);
                            await widget.onSuccessfulPayment();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusOverlay({
    required IconData icon,
    required String title,
    required String message,
    required String footer,
    required bool showLoader,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF102013),
            Color(0xFF0D1712),
            Color(0xFF0B140F),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 88, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: kPrimaryGreenSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kPrimaryGreenMuted,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: kPrimaryGreen,
                  size: 46,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kTextSecondary,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (showLoader)
                const SizedBox(
                  height: 38,
                  width: 38,
                  child: CircularProgressIndicator(
                    color: kPrimaryGreen,
                    backgroundColor: Colors.transparent,
                    strokeWidth: 2.6,
                  ),
                ),
              if (action != null) ...[
                const SizedBox(height: 12),
                action,
              ],
              const Spacer(),
              Text(
                footer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['id'] ?? "";
    } catch (e) {
      return "";
    }
  }

  Future<void> _savePayment(String transaccionId, String status) async {
    try {
      await widget.homeCubit.savePaymentRecord(
        transactionId: transaccionId,
        reference: widget.reference,
        status: status,
        amountInCents: widget.amountInCents,
        wompiFee: widget.wompiFee,
        loanId: widget.loanId,
        installmentNumber: widget.installmentNumber,
        installmentsToPay: widget.installmentsToPay,
      );
    } catch (_) {
      // Best-effort, no bloquea el flujo
    }
  }

  Future<void> getTransaccionStatus(String transaccionId) async {
    final dio = Dio();
    const url = "https://production.wompi.co/v1/transactions";
    var response = await dio.get(
      "$url/$transaccionId",
    );
    final String status = response.data["data"]["status"];
    debugPrint('response: $status');
    if (status == "APPROVED") {
      _timer?.cancel();
      _isLocked = false;
      setState(() {
        _procesingPayment = false;
        _showApprovedState = true;
      });
      await _savePayment(transaccionId, status);
    } else if (status == "DECLINED") {
      _timer?.cancel();
      _isLocked = false;
      _procesingPayment = false;
      await _savePayment(transaccionId, status);

      context.pop();
      ModalbottomsheetUtils.customError(
        context,
        'Ha ocurrido un error',
        "Ha ocurrido un error al procesar tu pago, por favor intenta de nuevo",
      );
    } else if (status == "ERROR" || status.isEmpty) {
      _timer?.cancel();
      _isLocked = false;
      _procesingPayment = false;
      await _savePayment(transaccionId, status);

      context.pop();
      ModalbottomsheetUtils.customError(
        context,
        'Ha ocurrido un error',
        "Ha ocurrido un error al procesar tu pago, por favor intenta de nuevo",
      );
    }
  }
}
