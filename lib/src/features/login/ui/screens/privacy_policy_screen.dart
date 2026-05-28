import 'package:flutter/material.dart';
import '../../../../utils/design_tokens.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(kBgScreen)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_privacyHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgScreen,
      appBar: AppBar(
        backgroundColor: kBgScreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: kPrimaryGreen),
            ),
        ],
      ),
    );
  }
}

const String _privacyHtml = '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      background-color: #0d1712;
      color: #D9D2C4b3;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 15px;
      line-height: 1.7;
      padding: 24px 20px 48px 20px;
      margin: 0;
    }
    h1 { color: #F6F2E9; font-size: 22px; margin-bottom: 4px; }
    h2 { color: #F6F2E9; font-size: 16px; margin-top: 28px; margin-bottom: 8px; }
    p { margin: 0 0 12px 0; }
    ul { padding-left: 20px; margin: 0 0 12px 0; }
    li { margin-bottom: 6px; }
    .version { color: #A6C48A; font-size: 12px; margin-bottom: 24px; }
    .divider { border: none; border-top: 1px solid #ffffff18; margin: 20px 0; }
  </style>
</head>
<body>
  <h1>Política de Privacidad</h1>
  <p class="version">v2.0.0 · El Desembale · Vigente desde mayo 2026</p>

  <p>En <strong>El Desembale</strong> nos comprometemos a proteger la privacidad y los datos personales de nuestros usuarios. Esta política describe cómo recopilamos, usamos y resguardamos su información.</p>

  <hr class="divider">

  <h2>1. Responsable del tratamiento</h2>
  <p><strong>El Desembale</strong> es responsable del tratamiento de los datos personales recopilados a través de esta aplicación, de conformidad con la Ley 1581 de 2012 y el Decreto 1377 de 2013 de la República de Colombia.</p>

  <h2>2. Datos que recopilamos</h2>
  <p>Recopilamos la siguiente información para prestar nuestros servicios:</p>
  <ul>
    <li>Nombre completo y número de identificación.</li>
    <li>Número de teléfono móvil y correo electrónico.</li>
    <li>Fotografías de documentos de identidad y selfie de verificación.</li>
    <li>Información bancaria necesaria para el desembolso.</li>
    <li>Dirección de residencia y referencias personales.</li>
    <li>Comprobante de domicilio (factura de servicios públicos).</li>
    <li>Historial de solicitudes y pagos dentro de la plataforma.</li>
  </ul>

  <h2>3. Finalidad del tratamiento</h2>
  <p>Sus datos se utilizan exclusivamente para:</p>
  <ul>
    <li>Verificar su identidad y evaluar solicitudes de crédito.</li>
    <li>Gestionar el desembolso y cobro de préstamos.</li>
    <li>Enviar notificaciones relacionadas con su crédito.</li>
    <li>Cumplir con obligaciones legales y regulatorias.</li>
    <li>Prevenir el fraude y garantizar la seguridad de la plataforma.</li>
  </ul>

  <h2>4. Almacenamiento y seguridad</h2>
  <p>Los datos se almacenan en servidores seguros de Google Firebase con cifrado en tránsito y en reposo. Solo el personal autorizado de El Desembale tiene acceso a su información.</p>

  <h2>5. Compartición de datos</h2>
  <p>No vendemos ni compartimos sus datos personales con terceros, salvo en los siguientes casos:</p>
  <ul>
    <li>Cuando sea requerido por autoridades competentes conforme a la ley.</li>
    <li>Con proveedores de servicios de pago (Wompi) necesarios para procesar transacciones.</li>
    <li>Con proveedores de comunicaciones (Twilio) para el envío de SMS de verificación.</li>
  </ul>

  <h2>6. Derechos del titular</h2>
  <p>Usted tiene derecho a:</p>
  <ul>
    <li>Conocer, actualizar y rectificar sus datos personales.</li>
    <li>Solicitar prueba de la autorización otorgada.</li>
    <li>Revocar la autorización y/o solicitar la supresión de sus datos.</li>
    <li>Presentar quejas ante la Superintendencia de Industria y Comercio (SIC).</li>
  </ul>

  <h2>7. Ejercicio de derechos</h2>
  <p>Para ejercer sus derechos, contáctenos a través del correo electrónico registrado en su cuenta o mediante los canales de atención disponibles en la aplicación.</p>

  <h2>8. Vigencia</h2>
  <p>Sus datos serán tratados durante el tiempo en que mantenga una relación activa con El Desembale y por el período adicional que exija la ley colombiana para obligaciones financieras.</p>

  <h2>9. Cambios a esta política</h2>
  <p>Nos reservamos el derecho de actualizar esta política. Cualquier cambio significativo será notificado a través de la aplicación.</p>

  <hr class="divider">
  <p style="font-size:12px; color:#9bb09f;">El Desembale · Colombia · v2.0.0</p>
</body>
</html>
''';
