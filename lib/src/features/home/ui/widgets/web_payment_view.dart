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
  final HomeCubit homeCubit;

  const WebPaymentView({
    super.key,
    required this.paymentUrl,
    required this.homeCubit,
  });

  @override
  State<WebPaymentView> createState() => _WebPaymentViewState();
}

class name extends StatelessWidget {
  const name({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
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
              _procesingPayment
                  ? Container(
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      color: Colors.white.withOpacity(0.8),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Estamos validando tu pago",
                              style: TextStyle(
                                color: UIColors.primaryBlack,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 50),
                            Text(
                              "Este proceso puede tardar unos minutos\npor favor no cierres la aplicación",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: UIColors.primaryBlack,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 50),
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                color: UIColors.primaryBlack,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
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

  Future<void> getTransaccionStatus(String transaccionId) async {
    final dio = Dio();
    // https://production.wompi.co/v1/transactions
    // https://sandbox.wompi.co/v1/transactions
    const url = "https://sandbox.wompi.co/v1/transactions";
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
      ModalbottomsheetUtils.successBottomSheet(
        context,
        'Tu pago ha sido aprobado',
        "vamos a continuar con el proceso",
        "Entendido",
        () async {
          context.pop(true);
          context.pop(true);
          context.pop(true);
          await widget.homeCubit.updateUserSubscription();
        },
      );
    } else if (status == "DECLINED") {
      _timer?.cancel();
      _isLocked = false;
      _procesingPayment = false;

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

      context.pop();
      ModalbottomsheetUtils.customError(
        context,
        'Ha ocurrido un error',
        "Ha ocurrido un error al procesar tu pago, por favor intenta de nuevo",
      );
    }
  }
}
