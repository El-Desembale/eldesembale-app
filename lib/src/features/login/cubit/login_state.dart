part of 'login_cubit.dart';

class LoginState {
  final bool isLoading;
  final String otp;
  final UserModel? user;
  final String countryCode;
  final String verificationId;
  String? error;
  LoginState({
    required this.isLoading,
    required this.otp,
    required this.countryCode,
    required this.verificationId,
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
    String? verificationId,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      otp: otp ?? this.otp,
      countryCode: countryCode ?? this.countryCode,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}
