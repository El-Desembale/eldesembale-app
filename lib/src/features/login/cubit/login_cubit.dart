// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../config/auth/cubit/auth_cubit.dart';
import '../../../config/auth/data/models/user_model.dart';
import '../../../config/routes/routes.dart';
import '../../../core/di/injection_dependency.dart';
import '../../../utils/images.dart';
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

  LoginCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._validatePhoneUseCase,
    this._changePasswordUseCase,
    this._sendOtpVerificationUseCase,
    this._verifyOtpUseCase,
  ) : super(
          LoginState(
            isLoading: false,
            otp: "",
            countryCode: "+57",
            verificationId: "",
          ),
        );

  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<bool> validateOtp({
    required BuildContext context,
  }) async {
    isLoading(true);
    final response = await _verifyOtpUseCase.call(
      verificationId: state.verificationId,
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
        showModalBottomSheet(
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
                const Text(
                  'Contraseña actualizada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () async {
                    context.pop();
                    context.pop();
                    context.push(AppRoutes.home);
                  },
                  child: Container(
                    height: 72,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
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
                            'Aceptar',
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
                              Icons.check_circle_outlined,
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
      },
      (user) {
        isLoading(false);
        showModalBottomSheet(
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
                const Text(
                  'Registro exitoso',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () async {
                    phoneController.text = "";
                    passwordController.text = "";
                    context.pop();
                    context.go(AppRoutes.home);
                  },
                  child: Container(
                    height: 72,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
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
                            'Aceptar',
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
                              Icons.check_circle_outlined,
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
      },
    );
  }

  Future<bool> sendOtpVerification({
    required BuildContext context,
  }) async {
    isLoading(true);
    final response = await _sendOtpVerificationUseCase.call(
      phone: phoneController.text,
      countryCode: state.countryCode,
    );
    return response.fold(
      (error) {
        isLoading(false);
        return false;
      },
      (verificationId) {
        emit(state.copyWith(verificationId: verificationId));
        _startTimer();
        isLoading(false);
        return true;
      },
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
          await sendOtpVerification(context: context);
          pageController.jumpToPage(2);
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
          context: context,
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
    showModalBottomSheet(
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
              'Contraseña incorrecta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
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

  void clear() {
    emit(
      LoginState(
        isLoading: false,
        otp: "",
        countryCode: "+57",
        verificationId: "",
      ),
    );
  }
}
