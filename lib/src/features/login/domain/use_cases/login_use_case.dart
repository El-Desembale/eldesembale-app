import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../config/auth/data/models/user_model.dart';
import '../repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository _loginRepository;

  LoginUseCase(
    this._loginRepository,
  );

  Future<Either<String, UserModel>> call({
    required String user,
    required String password,
    required BuildContext context,
  }) async {
    return await _loginRepository.login(
      user: user,
      password: password,
      context: context,
    );
  }
}
