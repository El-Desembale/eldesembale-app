import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../config/auth/cubit/auth_cubit.dart';

import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/data/reposotories/home_repository_impl.dart';
import '../../features/home/data/services/home_service.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/use_case/create_loan_use_case.dart';
import '../../features/home/domain/use_case/get_limits_use_case.dart';
import '../../features/home/domain/use_case/get_loans_use_case.dart';
import '../../features/home/domain/use_case/update_loan_use_case.dart';
import '../../features/home/domain/use_case/update_user_subscription_use_case.dart';
import '../../features/login/cubit/login_cubit.dart';
import '../../features/login/data/repositories/login_repository_impl.dart';
import '../../features/login/data/services/login_service.dart';
import '../../features/login/domain/repositories/login_repository.dart';
import '../../features/login/domain/use_cases/login_use_case.dart';
import '../../features/login/domain/use_cases/new_password_use_case.dart';
import '../../features/login/domain/use_cases/register_use_case.dart';
import '../../features/login/domain/use_cases/send_otp_verification_use_case.dart';
import '../../features/login/domain/use_cases/validate_phone_use_case.dart';
import '../../features/login/domain/use_cases/verift_otp_use_case.dart';

import '../preferences/shared_preference.dart';

final sl = GetIt.instance;

class Dependencies {
  Future<void> setup() async {
    _registerProviders();
    _registerRepositories();
    _registerUseCases();
    _registerDio();
    _registerDataSources();
  }

  Future<void> _registerProviders() async {
    sl.registerLazySingleton<AuthCubit>(
      () => AuthCubit(sl(instanceName: 'prefs')),
      instanceName: 'auth',
    );
    sl.registerFactory(
      () => HomeCubit(sl(), sl(), sl(), sl(), sl()),
    );
    sl.registerFactory(
      () => LoginCubit(sl(), sl(), sl(), sl(), sl(), sl()),
    );
  }

  // RegisterRepository
  Future<void> _registerRepositories() async {
    sl.registerLazySingleton<LoginRepository>(
      () => LoginRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(sl()),
    );
  }

  Future<void> _registerUseCases() async {
    sl.registerLazySingleton(
      () => LoginUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => ValidatePhoneUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => RegisterUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => SendOtpRecoveryPasswordUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => VerifyOtpRecoveryPasswordUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => ChangePasswordUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => GetLimitsUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => CreateLoanUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => GetLoansUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => UpdateUserSubscriptionUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => UpdateLoanUseCase(sl()),
    );
  }

  Future<void> _registerDataSources() async {
    sl.registerLazySingleton<LoginService>(
      () => LoginServiceImpl(
        sl(
          instanceName: 'firebaseDatabase',
        ),
      ),
    );
    sl.registerLazySingleton<HomeService>(
      () => HomeServiceImpl(
        sl(
          instanceName: 'firebaseDatabase',
        ),
      ),
    );
  }

  void _registerDio() {
    sl.registerSingleton<LocalSharedPreferences>(
      LocalSharedPreferences(),
      instanceName: 'prefs',
    );

    sl.registerSingleton<FirebaseFirestore>(
      FirebaseFirestore.instance,
      instanceName: 'firebaseDatabase',
    );
  }
}
