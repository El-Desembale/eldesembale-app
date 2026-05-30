part of 'home_cubit.dart';

const _homeStateNoChange = Object();

class HomeState {
  String? error;
  final bool isLoading;
  final LimitModel limits;
  final String paymentPeriod;
  final int selectedInstallments;
  final double totalLoanAmount;
  final LoanInformationEntity loanInformation;
  final int subscriptionAmount;
  final LoanInformationEntity? reusableLoanInformation;
  List<LoanRequestEntity> loans;
  // Perfil de riesgo del usuario
  final String riskProfile;
  final int maxLoanAmount;
  final bool isBlockedForNewLoans;
  HomeState({
    required this.limits,
    required this.paymentPeriod,
    required this.selectedInstallments,
    required this.totalLoanAmount,
    required this.loanInformation,
    required this.loans,
    this.subscriptionAmount = 22000,
    this.reusableLoanInformation,
    this.isLoading = false,
    this.error,
    this.riskProfile = 'NEW',
    this.maxLoanAmount = 200000,
    this.isBlockedForNewLoans = false,
  });

  HomeState copyWith({
    String? error,
    LimitModel? limits,
    String? paymentPeriod,
    int? selectedInstallments,
    bool? isLoading,
    double? totalLoanAmount,
    LoanInformationEntity? loanInformation,
    List<LoanRequestEntity>? loans,
    int? subscriptionAmount,
    Object? reusableLoanInformation = _homeStateNoChange,
    String? riskProfile,
    int? maxLoanAmount,
    bool? isBlockedForNewLoans,
  }) {
    return HomeState(
      error: error ?? this.error,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      selectedInstallments: selectedInstallments ?? this.selectedInstallments,
      limits: limits ?? this.limits,
      isLoading: isLoading ?? this.isLoading,
      totalLoanAmount: totalLoanAmount ?? this.totalLoanAmount,
      loanInformation: loanInformation ?? this.loanInformation,
      loans: loans ?? this.loans,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
      reusableLoanInformation: reusableLoanInformation == _homeStateNoChange
          ? this.reusableLoanInformation
          : reusableLoanInformation as LoanInformationEntity?,
      riskProfile: riskProfile ?? this.riskProfile,
      maxLoanAmount: maxLoanAmount ?? this.maxLoanAmount,
      isBlockedForNewLoans: isBlockedForNewLoans ?? this.isBlockedForNewLoans,
    );
  }
}
