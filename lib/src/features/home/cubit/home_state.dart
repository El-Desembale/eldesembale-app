part of 'home_cubit.dart';

class HomeState {
  String? error;
  final bool isLoading;
  final LimitModel limits;
  final String paymentPeriod;
  final int selectedInstallments;
  final double totalLoanAmount;
  final LoanInformationEntity loanInformation;
  HomeState({
    required this.limits,
    required this.paymentPeriod,
    required this.selectedInstallments,
    required this.totalLoanAmount,
    required this.loanInformation,
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
  }) {
    return HomeState(
      error: error ?? this.error,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      selectedInstallments: selectedInstallments ?? this.selectedInstallments,
      limits: limits ?? this.limits,
      isLoading: isLoading ?? this.isLoading,
      totalLoanAmount: totalLoanAmount ?? this.totalLoanAmount,
      loanInformation: loanInformation ?? this.loanInformation,
    );
  }
}
