import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0d1f0d))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_termsHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1f0d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1f0d),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Términos y condiciones',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(47, 255, 0, 1),
              ),
            ),
        ],
      ),
    );
  }
}

const String _termsHtml = '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      background-color: #0d1f0d;
      color: #ffffffb3;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 14px;
      line-height: 1.6;
      padding: 16px 20px 40px;
      margin: 0;
    }
    h2 {
      color: #ffffff;
      font-size: 16px;
      margin-top: 24px;
      margin-bottom: 8px;
    }
    ul {
      padding-left: 20px;
    }
    li {
      margin-bottom: 6px;
    }
  </style>
</head>
<body>

<h2>1. Aceptación de los términos</h2>
<p>Al registrarte y usar la aplicación El Desembale, aceptas estos términos y condiciones en su totalidad. Si no estás de acuerdo, no debes usar la aplicación.</p>

<h2>2. Uso del servicio</h2>
<p>El Desembale es una plataforma de préstamos personales. Al solicitar un préstamo, te comprometes a proporcionar información veraz y completa.</p>

<h2>3. Responsabilidades del usuario</h2>
<ul>
  <li>Mantener la confidencialidad de tu contraseña.</li>
  <li>Proporcionar datos personales verídicos.</li>
  <li>Cumplir con los pagos en las fechas acordadas.</li>
  <li>Notificar cualquier uso no autorizado de tu cuenta.</li>
</ul>

<h2>4. Condiciones de los préstamos</h2>
<p>Los montos, tasas de interés y plazos serán informados antes de la aprobación. Al aceptar un préstamo, te comprometes a pagar las cuotas según el calendario establecido.</p>

<h2>5. Privacidad</h2>
<p>Tu información personal será tratada de acuerdo con nuestra política de privacidad. No compartiremos tus datos con terceros sin tu consentimiento.</p>

<h2>6. Modificaciones</h2>
<p>Nos reservamos el derecho de modificar estos términos. Los cambios serán notificados a través de la aplicación.</p>

<h2>7. Contacto</h2>
<p>Para dudas o reclamos, contáctanos a través de los canales disponibles en la aplicación.</p>

</body>
</html>
''';
