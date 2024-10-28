import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../models/limit_model.dart';
import '../repositories/home_repository.dart';

class GetLimitsUseCase {
  final HomeRepository _homeRepository;

  GetLimitsUseCase(
    this._homeRepository,
  );

  Future<Either<ErrorModel, LimitModel>> call() async {
    return await _homeRepository.getLimits();
  }
}
