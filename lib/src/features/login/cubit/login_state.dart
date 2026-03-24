part of 'login_cubit.dart';

class LoginState {
  final bool isLoading;
  final String otp;
  final UserModel? user;
  final String countryCode;
  final String otpEmail;
  String? error;
  LoginState({
    required this.isLoading,
    required this.otp,
    required this.countryCode,
    this.otpEmail = '',
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
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      otp: otp ?? this.otp,
      countryCode: countryCode ?? this.countryCode,
      otpEmail: otpEmail ?? this.otpEmail,
    );
  }
}
