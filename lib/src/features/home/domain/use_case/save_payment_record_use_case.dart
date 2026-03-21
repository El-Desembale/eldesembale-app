import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../repositories/home_repository.dart';

class SavePaymentRecordUseCase {
  final HomeRepository _homeRepository;

  SavePaymentRecordUseCase(
    this._homeRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required String transactionId,
    required String reference,
    required String type,
    required String status,
    required int amountInCents,
    required String userPhone,
    required String userEmail,
    required String userName,
    String? loanId,
    int? installmentNumber,
  }) async {
    return await _homeRepository.savePaymentRecord(
      transactionId: transactionId,
      reference: reference,
      type: type,
      status: status,
      amountInCents: amountInCents,
      userPhone: userPhone,
      userEmail: userEmail,
      userName: userName,
      loanId: loanId,
      installmentNumber: installmentNumber,
    );
  }
}
