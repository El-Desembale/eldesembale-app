import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../../data/entities/loan_information_entity.dart';
import '../repositories/home_repository.dart';

class CreateLoanUseCase {
  final HomeRepository _homeRepository;

  CreateLoanUseCase(
    this._homeRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required int selectedInstallments,
    required double interest,
    required double totalLoanAmount,
    required String paymentPeriod,
    required String phone,
    required LoanInformationEntity loan,
  }) async {
    return await _homeRepository.createLoan(
      selectedInstallments: selectedInstallments,
      interest: interest,
      totalLoanAmount: totalLoanAmount,
      paymentPeriod: paymentPeriod,
      loan: loan,
      phone: phone,
    );
  }
}
