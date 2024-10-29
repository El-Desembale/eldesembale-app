import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../../data/entities/loan_request_entity.dart';
import '../repositories/home_repository.dart';

class GetLoansUseCase {
  final HomeRepository _homeRepository;

  GetLoansUseCase(
    this._homeRepository,
  );

  Future<Either<ErrorModel, List<LoanRequestEntity>>> call({
    required String phone,
  }) async {
    return await _homeRepository.getLoans(
      phone: phone,
    );
  }
}
