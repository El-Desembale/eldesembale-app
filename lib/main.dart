import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/core/di/injection_dependency.dart';
import 'src/core/preferences/shared_preference.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de que el framework esté inicializado

  // Mantén el splash screen visible hasta que se complete la inicialización
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await LocalSharedPreferences.init();
  await Dependencies().setup();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // Añadir un delay de 1 segundo antes de iniciar la app
  await Future.delayed(const Duration(seconds: 2));

  // Quitar el splash screen
  FlutterNativeSplash.remove();

  runApp(const MyApp()); // Iniciar la aplicación
}
