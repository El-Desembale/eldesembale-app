class UserEntity {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final bool isSubscribed;
  // Perfil de riesgo y cupo (calculados por backend)
  final String riskProfile;
  final int maxLoanAmount;
  final bool isBlockedForNewLoans;

  UserEntity({
    this.id = '',
    required this.email,
    required this.phone,
    required this.name,
    required this.lastName,
    required this.isSubscribed,
    this.riskProfile = 'NEW',
    this.maxLoanAmount = 100000,
    this.isBlockedForNewLoans = false,
  });
}
