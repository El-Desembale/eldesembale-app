import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../repositories/login_repository.dart';

class GetEmailByPhoneUseCase {
  final LoginRepository _loginRepository;

  GetEmailByPhoneUseCase(
    this._loginRepository,
  );

  Future<Either<ErrorModel, String?>> call({
    required String phone,
  }) async {
    return await _loginRepository.getEmailByPhone(
      phone: phone,
    );
  }
}
