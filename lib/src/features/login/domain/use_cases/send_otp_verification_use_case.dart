import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../repositories/login_repository.dart';

class SendOtpRecoveryPasswordUseCase {
  final LoginRepository _loginRepository;

  SendOtpRecoveryPasswordUseCase(
    this._loginRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required String email,
  }) async {
    return await _loginRepository.sendEmailOtp(
      email: email,
    );
  }
}
