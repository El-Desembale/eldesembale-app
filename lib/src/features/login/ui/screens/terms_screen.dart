import 'package:flutter/material.dart';
import '../../../../utils/design_tokens.dart';
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
      ..setBackgroundColor(kBgScreen)
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
      backgroundColor: kBgScreen,
      appBar: AppBar(
        backgroundColor: kBgScreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Términos y condiciones',
          style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: kPrimaryGreen,
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
      background-color: #0d1712;
      color: #D9D2C4b3;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 14px;
      line-height: 1.6;
      padding: 16px 20px 40px;
      margin: 0;
    }
    h2 {
      color: #F6F2E9;
      font-size: 16px;
      margin-top: 24px;
      margin-bottom: 8px;
    }
    .version { color: #A6C48A; font-size: 12px; margin-bottom: 20px; }
    ul {
      padding-left: 20px;
    }
    li {
      margin-bottom: 6px;
    }
  </style>
</head>
<body>

<p class="version">v2.0.0 · El Desembale · Vigente desde mayo de 2026 · Colombia</p>

<p>Los presentes Términos y Condiciones regulan el uso de la plataforma El Desembale y la solicitud de créditos de consumo por personas naturales en Colombia. Al registrarte y usar la plataforma, aceptas estos términos en su totalidad.</p>

<h2>1. Marco legal</h2>
<ul>
  <li>Ley 1480 de 2011 — Estatuto del Consumidor.</li>
  <li>Ley 1581 de 2012 — Protección de datos personales.</li>
  <li>Ley 1266 de 2008 — Habeas data financiero.</li>
  <li>Normas de la Superintendencia Financiera y de la Superintendencia de Industria y Comercio aplicables.</li>
</ul>

<h2>2. Requisitos del solicitante</h2>
<ul>
  <li>Ser persona natural mayor de edad y residente en Colombia.</li>
  <li>Contar con documento de identidad vigente.</li>
  <li>Tener una cuenta bancaria activa a tu nombre.</li>
  <li>Suministrar información veraz, completa y actualizada.</li>
</ul>

<h2>3. Cupo y perfil de crédito</h2>
<p>El cupo asignado depende de tu perfil y comportamiento de pago. Los nuevos clientes inician con un cupo de hasta \$200.000. Pagando de forma oportuna y completa, el cupo puede incrementarse progresivamente hasta un máximo de \$1.000.000. La presencia de mora puede limitar o bloquear el acceso a nuevos créditos.</p>

<h2>4. Intereses, costos y tasa de usura</h2>
<p>El valor total a pagar incluye el capital más los intereses informados de forma clara antes de confirmar la solicitud. Las tasas aplicadas no superarán la tasa máxima de interés permitida (tasa de usura) certificada por la Superintendencia Financiera de Colombia. No se cobran costos ocultos: el valor de cada cuota y el total se muestran antes de aceptar.</p>

<h2>5. Suscripción</h2>
<p>El acceso a la solicitud de créditos puede requerir una suscripción activa, cuyo valor se informa al momento del pago y se procesa de forma segura a través de Wompi.</p>

<h2>6. Proceso de aprobación y desembolso</h2>
<p>Toda solicitud pasa por los estados: Pendiente, En revisión, Aprobada o Rechazada y, finalmente, Desembolsada. La aprobación está sujeta a verificación y análisis de riesgo. El desembolso se realiza a la cuenta bancaria registrada por el solicitante.</p>

<h2>7. Pago y mora</h2>
<ul>
  <li>Debes pagar las cuotas en las fechas establecidas.</li>
  <li>El incumplimiento podrá generar intereses de mora dentro de los límites legales.</li>
  <li>El comportamiento de pago podrá ser reportado a centrales de riesgo conforme a la Ley 1266 de 2008, previa comunicación.</li>
</ul>

<h2>8. Derecho de retracto</h2>
<p>De conformidad con el artículo 47 de la Ley 1480 de 2011, podrás ejercer el derecho de retracto dentro de los términos legales aplicables a operaciones de crédito celebradas a distancia, cuando proceda.</p>

<h2>9. Obligaciones del usuario</h2>
<ul>
  <li>Mantener actualizada tu información de contacto y bancaria.</li>
  <li>No suplantar la identidad de terceros ni suministrar información falsa.</li>
  <li>Usar la plataforma de manera lícita y conforme a estos términos.</li>
</ul>

<h2>10. Atención al consumidor</h2>
<p>Para peticiones, quejas, reclamos o sugerencias (PQRS) puedes comunicarte a través de los canales de atención de la aplicación y el correo registrado en tu cuenta. Daremos respuesta dentro de los términos legales.</p>

<h2>11. Modificaciones</h2>
<p>El Desembale podrá actualizar estos términos. Los cambios sustanciales serán comunicados a través de la aplicación o el sitio web y regirán a partir de su publicación.</p>

</body>
</html>
''';
