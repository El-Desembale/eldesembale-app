import 'package:dartz/dartz.dart';

import 'package:desembale/src/core/erros/erros.dart';

import 'package:desembale/src/features/home/domain/models/limit_model.dart';

import '../../domain/repositories/home_repository.dart';
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
}
