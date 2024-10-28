import 'package:dartz/dartz.dart';

import '../../../../core/erros/erros.dart';
import '../models/limit_model.dart';

abstract class HomeRepository {
  Future<Either<ErrorModel, LimitModel>> getLimits();
}
