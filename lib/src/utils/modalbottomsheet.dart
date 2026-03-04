import 'package:desembale/src/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'images.dart';

class ModalbottomsheetUtils {
  static Future<void> invalidOtp(BuildContext context) {
    return showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      context: context,
      builder: (context) => Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 64,
              width: 64,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(20, 255, 255, 255),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SvgPicture.asset(
                AssetImages.cancel,
              ),
            ),
            const Spacer(),
            const Text(
              'Código incorrecto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'El código ingresado es incorrecto.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                context.pop();
              },
              child: Container(
                height: 72,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        'Volver a intentar',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: 72,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 47, 255, 0)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.replay_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
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
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      context: context,
      builder: (context) => Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 64,
              width: 64,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(20, 255, 255, 255),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SvgPicture.asset(
                AssetImages.cancel,
              ),
            ),
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                context.pop();
              },
              child: Container(
                height: 72,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        'Volver a intentar',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: 72,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 47, 255, 0)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.replay_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
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
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      context: context,
      builder: (context) => Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            if (title != '¿Deseas editar tus datos?')
              Container(
                height: 64,
                width: 64,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(20, 255, 255, 255),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SvgPicture.asset(
                  AssetImages.done,
                ),
              ),
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onTapp ??
                  () async {
                    context.pop();
                  },
              child: Container(
                height: 72,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 47, 255, 0),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: 72,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 47, 255, 0)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  static Future<void> loanSubmittedSheet(BuildContext context) {
    return showModalBottomSheet(
      isDismissible: false,
      backgroundColor: const Color.fromARGB(255, 6, 16, 0),
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
                  color: const Color.fromRGBO(47, 255, 0, 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color.fromRGBO(47, 255, 0, 1),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Solicitud enviada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Unbounded',
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Revisaremos tu solicitud y te notificaremos pronto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14,
                ),
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
                    color: const Color.fromRGBO(47, 255, 0, 1),
                    borderRadius: BorderRadius.circular(48),
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
                            borderRadius: BorderRadius.circular(32),
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
                    borderRadius: BorderRadius.circular(48),
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
                            borderRadius: BorderRadius.circular(32),
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
}
