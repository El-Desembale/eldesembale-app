import '../../data/entities/limit_entity.dart';

class LimitModel extends LimitEntity {
  LimitModel({
    required super.selectedSegment,
    required super.minAmmount,
    required super.maxAmmount,
    required super.maxInstallments,
    required super.interest,
  });

  LimitModel copyWith({
    int? selectedSegment,
    int? minAmmount,
    int? maxAmmount,
    int? maxInstallments,
    double? interest,
  }) {
    return LimitModel(
      selectedSegment: selectedSegment ?? this.selectedSegment,
      minAmmount: minAmmount ?? this.minAmmount,
      maxAmmount: maxAmmount ?? this.maxAmmount,
      maxInstallments: maxInstallments ?? this.maxInstallments,
      interest: interest ?? this.interest,
    );
  }
}
