import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../repositories/login_repository.dart';

class VerifyOtpRecoveryPasswordUseCase {
  final LoginRepository _loginRepository;

  VerifyOtpRecoveryPasswordUseCase(
    this._loginRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required String verificationId,
    required String otp,
  }) async {
    return await _loginRepository.verifyOtp(
      verificationId: verificationId,
      otp: otp,
    );
  }
}
