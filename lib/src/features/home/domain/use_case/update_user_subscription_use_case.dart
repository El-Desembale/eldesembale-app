import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../repositories/home_repository.dart';

class UpdateUserSubscriptionUseCase {
  final HomeRepository _homeRepository;

  UpdateUserSubscriptionUseCase(
    this._homeRepository,
  );

  Future<Either<ErrorModel, bool>> call({
    required String email,
  }) async {
    return await _homeRepository.updateUserSubscription(
      email: email,
    );
  }
}
