import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_dependency.dart';
import '../../core/preferences/shared_preference.dart';

import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/ui/screens/home_screen.dart';
import '../../features/home/ui/screens/loan_information_screen.dart';
import '../../features/home/ui/screens/loans_information/loan_bank_account_screen.dart';
import '../../features/home/ui/screens/loans_information/loan_camera_screen.dart';
import '../../features/home/ui/screens/loans_information/loan_data_collect_screen.dart';
import '../../features/home/ui/screens/loans_information/loan_direction_screen.dart';
import '../../features/home/ui/screens/loans_information/loan_reference_screen.dart';
import '../../features/home/ui/screens/loans_information/loan_selfie_screen.dart';
import '../../features/home/ui/screens/loans_list_screens.dart';
import '../../features/login/cubit/login_cubit.dart';
import '../../features/login/ui/screens/login_screen.dart';
import '../../features/login/ui/screens/recovery_password_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/splash/splash.dart';

class AppRoutes {
  static const onboarding = '/onboarding';
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const recoveryPassword = '/recovery-password';
  static const loanInformation = '/loan-information';
  static const loanDataCollect = '/loan-data-collect';
  static const loanDirection = '/loan-direction';
  static const loanCamera = '/loan-camera';
  static const loanSelfie = '/loan-selfie';
  static const loanRefences = '/loan-references';
  static const loanBankAccount = '/loan-bank-account';
  static const loansList = '/loans-list';

  static final LoginCubit _loginCubit = sl<LoginCubit>();
  static final HomeCubit _homeCubit = sl<HomeCubit>();
  static final _prefs = sl<LocalSharedPreferences>(
    instanceName: 'prefs',
  );

  static String get initialRoute => splash;

  static final List<RouteBase> routes = [
    GoRoute(
      path: splash,
      pageBuilder: (context, state) => NoTransitionPage(
        child: SplashScreen(
          prefs: _prefs,
        ),
      ),
    ),
    GoRoute(
      path: onboarding,
      pageBuilder: (context, state) => NoTransitionPage(
        child: OnboardingScreen(
          prefs: _prefs,
        ),
      ),
    ),
    GoRoute(
      path: login,
      pageBuilder: (context, state) => NoTransitionPage(
        child: LoginScreen(
          loginCubit: _loginCubit,
        ),
      ),
    ),
    GoRoute(
      path: home,
      pageBuilder: (context, state) => NoTransitionPage(
        child: HomeScreen(
          homeCubit: _homeCubit,
        ),
      ),
    ),
    GoRoute(
      path: recoveryPassword,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: RecoveryPasswordScreen(
            loginCubit: _loginCubit,
          ),
        );
      },
    ),
    GoRoute(
      path: loanInformation,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: LoanInformationScreen(
            homeCubit: _homeCubit,
          ),
        );
      },
    ),
    GoRoute(
      path: loanDataCollect,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: LoanDataCollectScreen(
            homeCubit: _homeCubit,
          ),
        );
      },
    ),
    GoRoute(
      path: loanDirection,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: LoanDirectionScreen(
            homeCubit: _homeCubit,
          ),
        );
      },
    ),
    GoRoute(
      path: loanCamera,
      pageBuilder: (context, state) {
        final onFileSelected = state.extra as void Function(File)?;
        return NoTransitionPage(
          child: LoanCameraScreen(
            addFile: onFileSelected!,
          ),
        );
      },
    ),
    GoRoute(
      path: loanSelfie,
      pageBuilder: (context, state) {
        final onFileSelected = state.extra as void Function(File)?;
        return NoTransitionPage(
          child: LoanSelfieScreen(
            addFile: onFileSelected!,
          ),
        );
      },
    ),
    GoRoute(
      path: loanRefences,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: LoanRefencesScreen(
            homeCubit: _homeCubit,
          ),
        );
      },
    ),
    GoRoute(
      path: loanBankAccount,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: LoanBankAccountScreen(
            homeCubit: _homeCubit,
          ),
        );
      },
    ),
    GoRoute(
      path: loansList,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: LoansListScreen(
            homeCubit: _homeCubit,
          ),
        );
      },
    ),
  ];
  static final routerConfig = GoRouter(
    initialLocation: initialRoute,
    routes: routes,
    errorPageBuilder: (context, state) {
      return MaterialPage(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Error"),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).go(AppRoutes.home);
                  },
                  child: const Text("Redirect"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
