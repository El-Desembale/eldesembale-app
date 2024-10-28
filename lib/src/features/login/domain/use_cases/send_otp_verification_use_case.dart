import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../repositories/login_repository.dart';

class SendOtpRecoveryPasswordUseCase {
  final LoginRepository _loginRepository;

  SendOtpRecoveryPasswordUseCase(
    this._loginRepository,
  );

  Future<Either<ErrorModel, String>> call({
    required String phone,
    required String countryCode,
  }) async {
    return await _loginRepository.sendOtpVerification(
      phone: phone,
      countryCode: countryCode,
    );
  }
}
