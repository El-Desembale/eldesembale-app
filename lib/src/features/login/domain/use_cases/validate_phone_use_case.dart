import 'package:dartz/dartz.dart';
import '../../../../core/erros/erros.dart';
import '../repositories/login_repository.dart';

class ValidatePhoneUseCase {
  final LoginRepository _loginRepository;

  ValidatePhoneUseCase(
    this._loginRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required String phone,
  }) async {
    return await _loginRepository.validatePhone(
      phone: phone,
    );
  }
}
