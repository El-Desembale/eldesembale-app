import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../config/auth/data/models/user_model.dart';
import '../../../../core/erros/erros.dart';
import '../../domain/repositories/login_repository.dart';
import '../services/login_service.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginService _loginService;

  LoginRepositoryImpl(
    this._loginService,
  );

  @override
  Future<Either<String, UserModel>> login({
    required String user,
    required String password,
    required BuildContext context,
  }) async {
    try {
      return Right(
        await _loginService.login(
          user: user,
          password: password,
          context: context,
        ),
      );
    } on Exception catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<ErrorModel, bool>> sendEmailOtp({
    required String email,
  }) async {
    try {
      return Right(
        await _loginService.sendEmailOtp(
          email: email,
        ),
      );
    } on Exception catch (e) {
      return Left(
        ErrorModel(
          code: 'xxx',
          message: e.toString().split("Exception:").last,
        ),
      );
    }
  }

  @override
  Future<Either<ErrorModel, String?>> getEmailByPhone({
    required String phone,
  }) async {
    try {
      return Right(
        await _loginService.getEmailByPhone(
          phone: phone,
        ),
      );
    } on Exception catch (e) {
      return Left(
        ErrorModel(
          code: 'xxx',
          message: e.toString().split("Exception:").last,
        ),
      );
    }
  }

  @override
  Future<Either<ErrorModel, bool>> newPassword({
    required String phone,
    required String password,
  }) async {
    try {
      return Right(
        await _loginService.newPassword(
          phone: phone,
          password: password,
        ),
      );
    } on Exception catch (e) {
      return Left(
        ErrorModel(
          code: 'xxx',
          message: e.toString().split("Exception:").last,
        ),
      );
    }
  }

  @override
  Future<Either<ErrorModel, bool>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      return Right(
        await _loginService.verifyEmailOtp(
          email: email,
          otp: otp,
        ),
      );
    } on Exception catch (e) {
      return Left(
        ErrorModel(
          code: 'xxx',
          message: e.toString().split("Exception:").last,
        ),
      );
    }
  }

  @override
  Future<Either<ErrorModel, bool>> validatePhone({
    required String phone,
  }) async {
    try {
      return Right(
        await _loginService.validatePhone(
          phone: phone,
        ),
      );
    } on Exception catch (e) {
      return Left(
        ErrorModel(
          code: 'xxx',
          message: e.toString().split("Exception:").last,
        ),
      );
    }
  }

  @override
  Future<Either<String, UserModel>> register({
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
    try {
      return Right(
        await _loginService.register(
          user: user,
          name: name,
          lastName: lastName,
          email: email,
          documentType: documentType,
          documentNumberm: documentNumberm,
          password: password,
          countryCode: countryCode,
          context: context,
        ),
      );
    } on Exception catch (e) {
      return Left(e.toString());
    }
  }
}
