import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../../data/entities/loan_information_entity.dart';
import '../../data/entities/loan_request_entity.dart';
import '../models/limit_model.dart';

abstract class HomeRepository {
  Future<Either<ErrorModel, LimitModel>> getLimits();
  Future<Either<ErrorModel, bool>> createLoan({
    required int selectedInstallments,
    required double interest,
    required double totalLoanAmount,
    required String paymentPeriod,
    required String phone,
    required LoanInformationEntity loan,
  });
  Future<Either<ErrorModel, List<LoanRequestEntity>>> getLoans({
    required String phone,
  });
  Future<Either<ErrorModel, bool>> updateUserSubscription({
    required String email,
  });
}
