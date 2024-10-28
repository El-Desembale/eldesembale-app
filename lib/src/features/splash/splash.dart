import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/routes.dart';
import '../../core/preferences/shared_preference.dart';

class SplashScreen extends StatefulWidget {
  final LocalSharedPreferences prefs;
  const SplashScreen({
    super.key,
    required this.prefs,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (widget.prefs.isFirstTime) {
          context.pushReplacement(AppRoutes.onboarding);
        } else {
          if (widget.prefs.isLogged) {
            context.pushReplacement(AppRoutes.home);
          } else {
            context.pushReplacement(AppRoutes.login);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/onboarding/splash.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
