part of 'login_cubit.dart';

class LoginState {
  final bool isLoading;
  final String otp;
  final UserModel? user;
  final String countryCode;
  final String otpEmail;
  final String smsVerificationId;
  final int timer;
  String? error;
  LoginState({
    required this.isLoading,
    required this.otp,
    required this.countryCode,
    this.otpEmail = '',
    this.smsVerificationId = '',
    this.timer = 0,
    this.user,
    this.error,
  });

  LoginState copyWith({
    bool? isLoading,
    int? timer,
    String? option,
    String? error,
    UserModel? user,
    String? otp,
    String? validateOtp,
    String? countryCode,
    String? otpEmail,
    String? smsVerificationId,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      otp: otp ?? this.otp,
      countryCode: countryCode ?? this.countryCode,
      otpEmail: otpEmail ?? this.otpEmail,
      smsVerificationId: smsVerificationId ?? this.smsVerificationId,
      timer: timer ?? this.timer,
    );
  }
}
