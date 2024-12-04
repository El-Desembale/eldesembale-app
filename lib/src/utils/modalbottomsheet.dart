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
}
