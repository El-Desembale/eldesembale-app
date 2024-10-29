class LimitEntity {
  final int selectedSegment;
  final int minAmmount;
  final int maxAmmount;
  final int maxInstallments;
  final double interest;

  LimitEntity({
    required this.selectedSegment,
    required this.minAmmount,
    required this.maxAmmount,
    required this.maxInstallments,
    required this.interest,
  });
}
