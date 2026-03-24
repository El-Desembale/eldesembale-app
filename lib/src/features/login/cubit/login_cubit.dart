// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/auth/cubit/auth_cubit.dart';
import '../../../config/auth/data/models/user_model.dart';
import '../../../config/routes/routes.dart';
import '../../../core/di/injection_dependency.dart';
import '../../../utils/modalbottomsheet.dart';
import '../domain/use_cases/get_email_by_phone_use_case.dart';
import '../domain/use_cases/login_use_case.dart';
import '../domain/use_cases/new_password_use_case.dart';
import '../domain/use_cases/register_use_case.dart';
import '../domain/use_cases/send_otp_verification_use_case.dart';
import '../domain/use_cases/validate_phone_use_case.dart';
import '../domain/use_cases/verift_otp_use_case.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final ValidatePhoneUseCase _validatePhoneUseCase;

  final SendOtpRecoveryPasswordUseCase _sendOtpVerificationUseCase;
  final VerifyOtpRecoveryPasswordUseCase _verifyOtpUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final GetEmailByPhoneUseCase _getEmailByPhoneUseCase;

  LoginCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._validatePhoneUseCase,
    this._changePasswordUseCase,
    this._sendOtpVerificationUseCase,
    this._verifyOtpUseCase,
    this._getEmailByPhoneUseCase,
  ) : super(
          LoginState(
            isLoading: false,
            otp: "",
            countryCode: "+57",
          ),
        );

  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<bool> validateOtp({
    required BuildContext context,
  }) async {
    isLoading(true);
    final response = await _verifyOtpUseCase.call(
      email: state.otpEmail,
      otp: state.otp,
    );
    return response.fold(
      (error) {
        isLoading(false);
        return false;
      },
      (user) {
        isLoading(false);
        return user;
      },
    );
  }

  Future<void> changePassword({
    required BuildContext context,
    required String password,
  }) async {
    isLoading(true);
    final response = await _changePasswordUseCase.call(
      phone: phoneController.text,
      password: password,
    );
    return response.fold(
      (error) {
        isLoading(false);
      },
      (user) {
        isLoading(false);
        updateOtp("");
        ModalbottomsheetUtils.successBottomSheet(
          context,
          'Contraseña actualizada',
          'Tu contraseña ha sido cambiada exitosamente.',
          'Aceptar',
          () {
            context.pop();
            context.pop();
            context.push(AppRoutes.home);
          },
        );
      },
    );
  }

  Future<void> register({
    required String user,
    required String name,
    required String lastName,
    required String email,
    required String documentType,
    required String documentNumberm,
    required String password,
    required String countryCode,
    required BuildContext context,
  }) async {
    isLoading(true);
    final response = await _registerUseCase.call(
      user: user,
      name: name,
      lastName: lastName,
      email: email,
      documentType: documentType,
      documentNumberm: documentNumberm,
      password: password,
      countryCode: countryCode,
      context: context,
    );
    return response.fold(
      (error) {
        isLoading(false);
        debugPrint('Register error: $error');
        if (context.mounted) {
          ModalbottomsheetUtils.customError(
            context,
            'Error en el registro',
            error,
          );
        }
      },
      (user) {
        isLoading(false);
        ModalbottomsheetUtils.successBottomSheet(
          context,
          'Registro exitoso',
          'Tu cuenta ha sido creada correctamente.',
          'Aceptar',
          () async {
            await sl<AuthCubit>(instanceName: 'auth').login(
              user: user,
            );
            phoneController.text = "";
            passwordController.text = "";
            context.pop();
            context.go(AppRoutes.home);
          },
        );
      },
    );
  }

  Future<bool> sendOtpVerification({
    required String email,
    required BuildContext context,
  }) async {
    isLoading(true);
    emit(state.copyWith(otpEmail: email));
    final response = await _sendOtpVerificationUseCase.call(
      email: email,
    );
    return response.fold(
      (error) {
        isLoading(false);
        return false;
      },
      (success) {
        _startTimer();
        isLoading(false);
        return success;
      },
    );
  }

  Future<String?> getEmailByPhone({
    required String phone,
  }) async {
    final response = await _getEmailByPhoneUseCase.call(phone: phone);
    return response.fold(
      (error) => null,
      (email) => email,
    );
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimerCount(timer.tick);
      if (timer.tick == 20) {
        timer.cancel();
        _updateTimerCount(20);
      }
    });
  }

  void _updateTimerCount(int value) {
    emit(
      state.copyWith(timer: value),
    );
  }

  Future<void> validatePhone({
    required BuildContext context,
    required PageController pageController,
  }) async {
    isLoading(true);
    final response = await _validatePhoneUseCase.call(
      phone: phoneController.text,
    );
    response.fold(
      (error) {
        showError(context, error.toString());
        isLoading(false);
      },
      (userModel) async {
        if (userModel) {
          pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        } else {
          pageController.jumpToPage(3);
        }
      },
    );
    isLoading(false);
  }

  Future<void> login({
    required BuildContext context,
  }) async {
    isLoading(true);
    final response = await _loginUseCase.call(
      user: phoneController.text,
      password: passwordController.text,
      context: context,
    );
    response.fold(
      (error) {
        showError(context, error);
        isLoading(false);
      },
      (userModel) async {
        await sl<AuthCubit>(instanceName: 'auth').login(
          user: userModel,
        );
        clear();
        passwordController.clear();
        phoneController.clear();
        context.pushReplacement(AppRoutes.home);
      },
    );
    isLoading(false);
  }

  void isLoading(bool isLoading) {
    emit(
      state.copyWith(isLoading: isLoading),
    );
  }

  void updateOtp(String otp) {
    emit(
      state.copyWith(otp: otp),
    );
  }

  void updateValidateOtp(String validateOtp) {
    emit(
      state.copyWith(validateOtp: validateOtp),
    );
  }

  void clearError() {
    emit(
      state.copyWith(error: null),
    );
  }

  void updateCountryCode(String countryCode) {
    emit(
      state.copyWith(countryCode: countryCode),
    );
  }

  void showError(BuildContext context, String error) {
    ModalbottomsheetUtils.customError(
      context,
      'Contraseña incorrecta',
      'La contraseña ingresada no es correcta. Inténtalo de nuevo.',
    );
  }

  void clear() {
    emit(
      LoginState(
        isLoading: false,
        otp: "",
        countryCode: "+57",
      ),
    );
  }
}
