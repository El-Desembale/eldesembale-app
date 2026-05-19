import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../../data/entities/loan_request_entity.dart';
import '../repositories/home_repository.dart';

class UpdateLoanUseCase {
  final HomeRepository _homeRepository;

  UpdateLoanUseCase(
    this._homeRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required LoanRequestEntity loan,
    int installmentsToPay = 1,
  }) async {
    return await _homeRepository.updateLoan(
      loan: loan,
      installmentsToPay: installmentsToPay,
    );
  }
}
