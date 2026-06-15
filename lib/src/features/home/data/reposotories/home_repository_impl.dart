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
    String? clientName,
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
          clientName: clientName,
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

  @override
  Future<Either<ErrorModel, bool>> updateLoan({
    required LoanRequestEntity loan,
    int installmentsToPay = 1,
  }) async {
    try {
      return Right(
        await _homeService.updateLoan(
          loan: loan,
          installmentsToPay: installmentsToPay,
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
  Future<Either<ErrorModel, bool>> savePaymentRecord({
    required String transactionId,
    required String reference,
    required String type,
    required String status,
    required int amountInCents,
    required int wompiFee,
    required String userPhone,
    required String userEmail,
    required String userName,
    String source = 'wompi',
    String? loanId,
    int? installmentNumber,
    int? installmentsToPay,
    String? proofUrl,
    String? proofName,
    String? proofContentType,
  }) async {
    try {
      return Right(
        await _homeService.savePaymentRecord(
          transactionId: transactionId,
          reference: reference,
          type: type,
          status: status,
          amountInCents: amountInCents,
          wompiFee: wompiFee,
          userPhone: userPhone,
          userEmail: userEmail,
          userName: userName,
          source: source,
          loanId: loanId,
          installmentNumber: installmentNumber,
          installmentsToPay: installmentsToPay,
          proofUrl: proofUrl,
          proofName: proofName,
          proofContentType: proofContentType,
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
