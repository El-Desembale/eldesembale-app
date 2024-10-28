import '../../data/entities/limit_entity.dart';

class LimitModel extends LimitEntity {
  LimitModel({
    required super.selectedSegment,
    required super.minAmmount,
    required super.maxAmmount,
  });

  LimitModel copyWith({
    int? selectedSegment,
    int? minAmmount,
    int? maxAmmount,
  }) {
    return LimitModel(
      selectedSegment: selectedSegment ?? this.selectedSegment,
      minAmmount: minAmmount ?? this.minAmmount,
      maxAmmount: maxAmmount ?? this.maxAmmount,
    );
  }
}
