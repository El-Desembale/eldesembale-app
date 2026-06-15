import 'package:desembale/src/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'design_tokens.dart';

class ModalbottomsheetUtils {
  static const _bg = kBgScreen;
  static const _green = kPrimaryGreen;

  static Future<void> invalidOtp(BuildContext context) {
    return showModalBottomSheet(
      isDismissible: true,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.error_outline,
                    color: Colors.red, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Código incorrecto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El código ingresado no es válido. Inténtalo de nuevo.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: kTextSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 28),
              _primaryButton(
                label: 'Volver a intentar',
                icon: Icons.replay_outlined,
                color: Colors.white,
                textColor: Colors.black,
                onTap: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> customError(
    BuildContext context,
    String title,
    String message,
  ) {
    return showModalBottomSheet(
      isDismissible: true,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: kTextSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 28),
              _primaryButton(
                label: 'Entendido',
                icon: Icons.close,
                color: Colors.white.withOpacity(0.1),
                textColor: Colors.white,
                onTap: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> successBottomSheet(
    BuildContext context,
    String title,
    String message,
    String buttonText,
    void Function()? onTapp,
  ) {
    return showModalBottomSheet(
      isDismissible: false,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != '¿Deseas editar tus datos?')
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: _green, size: 36),
                ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: kTextSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 28),
              _primaryButton(
                label: buttonText,
                icon: Icons.check,
                color: _green,
                textColor: Colors.black,
                onTap: onTapp ?? () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> loanSubmittedSheet(BuildContext context) {
    return showModalBottomSheet(
      isDismissible: false,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: _green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Solicitud enviada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Revisaremos tu solicitud y te notificaremos pronto.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: kTextSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.go(AppRoutes.loansList);
                },
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Text(
                          'Ver solicitudes',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Container(
                          width: 56,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.list_alt_outlined,
                              color: Colors.black, size: 26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.go(AppRoutes.home);
                },
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Text(
                          'Ir al inicio',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Container(
                          width: 56,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.home_outlined,
                              color: Colors.white.withOpacity(0.6), size: 26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> subscriptionApprovedSheet(
    BuildContext context, {
    required double selectedAmount,
    required VoidCallback onContinueLoan,
    required VoidCallback onGoHome,
  }) {
    final amountLabel =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)
            .format(selectedAmount);

    return showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: _green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Felicitaciones!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'El pago de tu suscripción ha sido aprobado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu solicitud por $amountLabel sigue lista para continuar. Puedes retomarla ahora o volver al inicio.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              _primaryButton(
                label: 'Continuar solicitud',
                icon: Icons.arrow_forward_rounded,
                color: _green,
                textColor: Colors.black,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onContinueLoan();
                },
              ),
              const SizedBox(height: 12),
              _primaryButton(
                label: 'Volver al home',
                icon: Icons.home_rounded,
                color: Colors.white.withOpacity(0.08),
                textColor: Colors.white,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onGoHome();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _primaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 56,
                height: 46,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: textColor, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
