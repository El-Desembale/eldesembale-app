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
  <h1>Política de Tratamiento de Datos Personales</h1>
  <p class="version">v2.0.0 · El Desembale · Vigente desde mayo de 2026 · Colombia</p>

  <p>En cumplimiento de la Ley Estatutaria 1581 de 2012, el Decreto 1377 de 2013 y demás normas concordantes que regulan la protección de datos personales en Colombia, <strong>El Desembale</strong> adopta la presente Política de Tratamiento de la Información, que regula la recolección, uso, almacenamiento y protección de los datos personales de nuestros usuarios (titulares).</p>

  <hr class="divider">

  <h2>1. Responsable del tratamiento</h2>
  <p>El Desembale actúa como responsable del tratamiento de los datos personales. Para el ejercicio de tus derechos puedes contactarnos a través de los canales de atención disponibles en la aplicación y en el correo registrado en tu cuenta.</p>

  <h2>2. Marco legal aplicable</h2>
  <ul>
    <li>Constitución Política de Colombia, artículo 15 (habeas data).</li>
    <li>Ley Estatutaria 1581 de 2012 — Protección de datos personales.</li>
    <li>Decreto Reglamentario 1377 de 2013.</li>
    <li>Ley 1266 de 2008 — Datos financieros, crediticios y de servicios.</li>
    <li>Vigilancia de la Superintendencia de Industria y Comercio (SIC).</li>
  </ul>

  <h2>3. Datos que recolectamos</h2>
  <ul>
    <li>Nombres y apellidos, tipo y número de documento de identidad.</li>
    <li>Número de teléfono celular y correo electrónico.</li>
    <li>Fotografías del documento de identidad (frontal y posterior) y selfie de verificación.</li>
    <li>Información bancaria necesaria para el desembolso y recaudo.</li>
    <li>Dirección de residencia y referencias personales.</li>
    <li>Comprobante de domicilio (factura de servicios públicos).</li>
    <li>Historial de solicitudes, pagos y comportamiento crediticio dentro de la plataforma.</li>
  </ul>

  <h2>4. Finalidades del tratamiento</h2>
  <ul>
    <li>Verificar tu identidad y prevenir el fraude y la suplantación.</li>
    <li>Evaluar y gestionar tus solicitudes de crédito (estudio de riesgo y cupo).</li>
    <li>Realizar el desembolso y el recaudo de las cuotas.</li>
    <li>Enviar notificaciones sobre el estado de tu crédito y recordatorios de pago.</li>
    <li>Reportar a centrales de riesgo conforme a la Ley 1266 de 2008, previa autorización.</li>
    <li>Cumplir obligaciones legales, contables, tributarias y de prevención de lavado de activos.</li>
  </ul>

  <h2>5. Autorización del titular</h2>
  <p>Al registrarte y usar la plataforma, otorgas tu autorización previa, expresa e informada para el tratamiento de tus datos conforme a esta política. Esta autorización es requisito para la prestación del servicio de crédito.</p>

  <h2>6. Derechos del titular (habeas data)</h2>
  <ul>
    <li>Conocer, actualizar y rectificar tus datos personales.</li>
    <li>Solicitar prueba de la autorización otorgada.</li>
    <li>Ser informado sobre el uso que se ha dado a tus datos.</li>
    <li>Presentar quejas ante la SIC por infracciones a la ley.</li>
    <li>Revocar la autorización y/o solicitar la supresión de los datos, cuando no exista un deber legal o contractual de conservarlos.</li>
    <li>Acceder gratuitamente a tus datos personales objeto de tratamiento.</li>
  </ul>

  <h2>7. Procedimiento para ejercer tus derechos</h2>
  <p>Puedes presentar consultas y reclamos a través del correo registrado en tu cuenta. Las consultas se atenderán en un término máximo de diez (10) días hábiles y los reclamos en máximo quince (15) días hábiles, conforme a los artículos 14 y 15 de la Ley 1581 de 2012.</p>

  <h2>8. Seguridad y conservación</h2>
  <p>Implementamos medidas técnicas, humanas y administrativas para proteger tus datos contra acceso no autorizado, pérdida o alteración. Los datos se almacenan en servidores con cifrado en tránsito y en reposo, y se conservan durante el tiempo que dure la relación y el período adicional exigido por la ley para obligaciones financieras.</p>

  <h2>9. Transferencia y transmisión de datos</h2>
  <p>No vendemos tus datos. Podremos compartirlos con proveedores que apoyan la operación (pasarela de pagos Wompi, verificación de identidad y mensajería) bajo acuerdos de confidencialidad, y con autoridades cuando la ley lo exija.</p>

  <h2>10. Vigencia</h2>
  <p>Esta política rige a partir de su publicación. Cualquier cambio sustancial será comunicado a través de la aplicación o el sitio web.</p>

  <hr class="divider">
  <p style="font-size:12px; color:#9bb09f;">El Desembale · Colombia · v2.0.0</p>
</body>
</html>
''';
