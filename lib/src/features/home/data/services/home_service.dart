import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/limit_model.dart';

abstract class HomeService {
  Future<LimitModel> getLimits();
}

class HomeServiceImpl implements HomeService {
  final FirebaseFirestore _database;
  HomeServiceImpl(
    this._database,
  );

  @override
  Future<LimitModel> getLimits() async {
    QuerySnapshot querySnapshot =
        await _database.collection('app_config').get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return LimitModel(
        maxAmmount: data['max_amount'],
        minAmmount: data['min_amount'],
        selectedSegment: 25,
      );
    } else {
      return LimitModel(
        maxAmmount: 50000,
        minAmmount: 10000,
        selectedSegment: 25,
      );
    }
  }
}
