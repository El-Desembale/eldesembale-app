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
    );
  }
}
