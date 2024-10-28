import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../config/auth/data/models/user_model.dart';
import '../repositories/login_repository.dart';

class RegisterUseCase {
  final LoginRepository _loginRepository;

  RegisterUseCase(
    this._loginRepository,
  );

  Future<Either<String, UserModel>> call({
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
    return await _loginRepository.register(
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
  }
}
