import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../../domain/models/limit_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../entities/loan_information_entity.dart';
import '../entities/loan_request_entity.dart';
import '../services/home_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeService _homeService;

  HomeRepositoryImpl(
    this._homeService,
  );

  @override
  Future<Either<ErrorModel, LimitModel>> getLimits() async {
    try {
      return Right(
        await _homeService.getLimits(),
      );
    } catch (e) {
      return Left(
        ErrorModel(
          code: '$e',
        ),
      );
    }
  }

  @override
  Future<Either<ErrorModel, bool>> createLoan({
    required int selectedInstallments,
    required double interest,
    required double totalLoanAmount,
    required String paymentPeriod,
    required LoanInformationEntity loan,
    required String phone,
  }) async {
    try {
      return Right(
        await _homeService.createLoan(
          loan: loan,
          interest: interest,
          paymentPeriod: paymentPeriod,
          selectedInstallments: selectedInstallments,
          totalLoanAmount: totalLoanAmount,
          phone: phone,
        ),
      );
    } catch (e) {
      return Left(
        ErrorModel(
          code: '$e',
        ),
      );
    }
  }

  @override
  Future<Either<ErrorModel, List<LoanRequestEntity>>> getLoans({
    required String phone,
  }) async {
    try {
      return Right(
        await _homeService.getLoans(
          phone: phone,
        ),
      );
    } catch (e) {
      return Left(
        ErrorModel(
          code: '$e',
        ),
      );
    }
  }

  @override
  Future<Either<ErrorModel, bool>> updateUserSubscription({
    required String email,
  }) async {
    try {
      return Right(
        await _homeService.updateUserSubscription(
          email: email,
        ),
      );
    } catch (e) {
      return Left(
        ErrorModel(
          code: '$e',
        ),
      );
    }
  }
}
