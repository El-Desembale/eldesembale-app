class LimitEntity {
  final int selectedSegment;
  final int minAmmount;
  final int maxAmmount;
  final int maxInstallments;
  final int minInstallments;
  final double interest;
  final double? budgetAvailable;

  LimitEntity({
    required this.selectedSegment,
    required this.minAmmount,
    required this.maxAmmount,
    required this.maxInstallments,
    required this.minInstallments,
    required this.interest,
    this.budgetAvailable,
  });
}
