import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../repositories/login_repository.dart';

class ChangePasswordUseCase {
  final LoginRepository _loginRepository;

  ChangePasswordUseCase(
    this._loginRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required String phone,
    required String password,
  }) async {
    return await _loginRepository.newPassword(
      phone: phone,
      password: password,
    );
  }
}
