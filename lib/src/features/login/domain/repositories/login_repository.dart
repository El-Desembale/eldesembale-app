import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../config/auth/data/models/user_model.dart';
import '../../../../core/erros/erros.dart';

abstract class LoginRepository {
  Future<Either<ErrorModel, bool>> validatePhone({
    required String phone,
  });
  Future<Either<String, UserModel>> login({
    required String user,
    required String password,
    required BuildContext context,
  });
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
  });
  Future<Either<ErrorModel, bool>> sendEmailOtp({
    required String email,
  });
  Future<Either<ErrorModel, bool>> verifyEmailOtp({
    required String email,
    required String otp,
  });
  Future<Either<ErrorModel, String?>> getEmailByPhone({
    required String phone,
  });
  Future<Either<ErrorModel, bool>> newPassword({
    required String phone,
    required String password,
  });
}
