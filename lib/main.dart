import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/config/routes/routes.dart';
import 'src/core/di/injection_dependency.dart';
import 'src/core/preferences/shared_preference.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await LocalSharedPreferences.init();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  await Dependencies().setup();

  // Determinar ruta inicial antes de mostrar la app
  final prefs = sl<LocalSharedPreferences>(instanceName: 'prefs');
  if (prefs.isFirstTime) {
    AppRoutes.overrideInitialRoute(AppRoutes.onboarding);
  } else if (prefs.isLogged) {
    AppRoutes.overrideInitialRoute(AppRoutes.home);
  } else {
    AppRoutes.overrideInitialRoute(AppRoutes.login);
  }

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}
