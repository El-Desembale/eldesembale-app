// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../cubit/home_cubit.dart';

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
              if (_procesingPayment)
                Container(
                  height: MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 6, 16, 0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Animated logo / icon
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(47, 255, 0, 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromRGBO(47, 255, 0, 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color.fromRGBO(47, 255, 0, 1),
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Validando tu pago',
                        style: TextStyle(
                          fontFamily: 'Unbounded',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Este proceso puede tardar unos segundos.\nPor favor no cierres la aplicación.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(47, 255, 0, 1),
                          backgroundColor: Colors.transparent,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Text(
                          'Pagos seguros por Wompi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                child: FloatingActionButton(
                  backgroundColor: UIColors.primaryBlack,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
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
      _procesingPayment = false;
      setState(() {});
      await _savePayment(transaccionId, status);
      ModalbottomsheetUtils.successBottomSheet(
        context,
        'Tu pago ha sido aprobado',
        "vamos a continuar con el proceso",
        "Entendido",
        () async {
          await widget.onSuccessfulPayment();
        },
      );
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
