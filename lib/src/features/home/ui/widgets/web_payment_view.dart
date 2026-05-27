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
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/primary_action_button.dart';

class WebPaymentView extends StatefulWidget {
  final String paymentUrl;
  final Future<void> Function() onSuccessfulPayment;
  final HomeCubit homeCubit;
  final String reference;
  final int amountInCents;
  final String? loanId;
  final int? installmentNumber;

  const WebPaymentView({
    super.key,
    required this.paymentUrl,
    required this.onSuccessfulPayment,
    required this.homeCubit,
    required this.reference,
    required this.amountInCents,
    this.loanId,
    this.installmentNumber,
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isLocked,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              WebViewWidget(
                controller: _controller,
              ),
              if (_hasExitedCheckout)
                Container(
                  color: const Color(0xFF0D1712),
                ),
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
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8, left: 16),
                child: BackCircleButton(
                  heroTag: 'wompi_back',
                  onPressed: () {
                    if (currentUrl
                        .contains("https://checkout.wompi.co/method")) {
                      context.pop();
                    } else {
                      _controller.goBack();
                    }
                  },
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
                  fontFamily: kDisplayFont,
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
        loanId: widget.loanId,
        installmentNumber: widget.installmentNumber,
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
