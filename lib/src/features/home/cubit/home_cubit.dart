// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import '../../../config/auth/cubit/auth_cubit.dart';
import '../../../core/di/injection_dependency.dart';
import '../../../utils/modalbottomsheet.dart';
import '../data/entities/loan_information_entity.dart';
import '../data/entities/loan_request_entity.dart';
import '../domain/models/limit_model.dart';
import '../domain/use_case/create_loan_use_case.dart';
import '../domain/use_case/get_limits_use_case.dart';
import '../domain/use_case/get_loans_use_case.dart';
import '../domain/use_case/update_loan_use_case.dart';
import '../domain/use_case/update_user_subscription_use_case.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetLimitsUseCase _getLimitsCase;
  final CreateLoanUseCase _createLoanUseCase;
  final GetLoansUseCase _getLoansUseCase;
  final UpdateUserSubscriptionUseCase _updateUserSubscriptionUseCase;
  final UpdateLoanUseCase _updateLoanUseCase;
  HomeCubit(
    this._getLimitsCase,
    this._createLoanUseCase,
    this._getLoansUseCase,
    this._updateUserSubscriptionUseCase,
    this._updateLoanUseCase,
  ) : super(
          HomeState(
            loanInformation: LoanInformationEntity.initial(),
            limits: LimitModel(
              selectedSegment: 25,
              minAmmount: 50000,
              maxAmmount: 500000,
              maxInstallments: 8,
              interest: 10.0,
            ),
            loans: [],
            selectedInstallments: 4,
            totalLoanAmount: 250000,
            paymentPeriod: 'Quincenal',
          ),
        );

  void clearError() {
    emit(
      state.copyWith(error: null),
    );
  }

  void updateSegmentFromPosition(BuildContext context, double dx) {
    final box = context.findRenderObject() as RenderBox;
    final newSegment = (dx / box.size.width * 55).clamp(0, 49).toInt();
    updateSelectedSegment(newSegment);
  }

  Future<String> generateSubscriptionPayment(BuildContext context) async {
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    final priv_key = dotenv.env['PRIVATE_INTEGRITY_KEY_TEST'];
    final public_key = dotenv.env['PUBLIC_TEST_KEY'];

    const amountInCents = 1900000;

    final reference =
        'subscription${user.phone}${DateTime.now().millisecondsSinceEpoch}';

    final integrity = _generateIntegrityHash(
      reference,
      amountInCents.toString(),
      priv_key ?? "",
    );
    final url = generateUrl(
      public_key ?? "",
      amountInCents,
      reference,
      integrity,
      user.email,
      '${user.name} ${user.lastName}',
      user.phone,
    );

    return url;
  }

  Future<String> generatePayment(
    BuildContext context,
    int amountInCents,
  ) async {
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    final priv_key = dotenv.env['PRIVATE_INTEGRITY_KEY_TEST'];
    final public_key = dotenv.env['PUBLIC_TEST_KEY'];

    amountInCents = amountInCents * 100;

    final reference =
        'payment${user.phone}${DateTime.now().millisecondsSinceEpoch}';

    final integrity = _generateIntegrityHash(
      reference,
      amountInCents.toString(),
      priv_key ?? "",
    );
    final url = generateUrl(
      public_key ?? "",
      amountInCents,
      reference,
      integrity,
      user.email,
      '${user.name} ${user.lastName}',
      user.phone,
    );

    return url;
  }

  String _generateIntegrityHash(
      String reference, String billingPrice, String secretKey) {
    final imput = '$reference${billingPrice}COP$secretKey';
    final bytes = utf8.encode(imput);
    final hash = sha256.convert(bytes);

    return hash.toString();
  }

  String generateUrl(String publicKey, int amountInCents, String reference,
      String integrity, String email, String name, String phone) {
    return "https://checkout.wompi.co/p/?public-key=$publicKey&currency=COP&amount-in-cents=$amountInCents&reference=$reference&signature:integrity=$integrity&tax-in-cents:vat=00&tax-in-cents:consumption=00&customer-data:email=$email&customer-data:full-name=$name&customer-data:phone-number=$phone&redirect-url=https://eldesembale.com.co";
  }

  void updateSelectedSegment(int newSegment) {
    emit(
      state.copyWith(
        limits: state.limits.copyWith(
          selectedSegment: newSegment,
        ),
      ),
    );
    final total = calculateDisplayValue() * 1.0;
    emit(
      state.copyWith(
        totalLoanAmount: total,
      ),
    );
  }

  int calculateDisplayValue() {
    return state.limits.minAmmount +
        ((state.limits.selectedSegment / 49) *
                    ((state.limits.maxAmmount - state.limits.minAmmount) /
                        10000))
                .toInt() *
            10000;
  }

  Future<void> getLimits() async {
    isLoading(true);
    final response = await _getLimitsCase.call();

    response.fold(
      (error) => setError(error.toString()),
      (limits) {
        setLimits(limits);
      },
    );
    isLoading(false);
  }

  void setLimits(LimitModel newLimits) {
    emit(
      state.copyWith(
        limits: newLimits,
      ),
    );
  }

  void updateInstallments(int newInstallments) {
    emit(
      state.copyWith(
        selectedInstallments: newInstallments,
      ),
    );
  }

  void updatePaymentPeriod(String newPaymentPeriod) {
    emit(
      state.copyWith(
        paymentPeriod: newPaymentPeriod,
      ),
    );
  }

  void updateDirection(String newDirection) {
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          direction: newDirection,
        ),
      ),
    );
  }

  void addEmpInvoiceFile(File file) {
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          empInvoiceFile: file,
        ),
      ),
    );
  }

  void addFrontIdFile(File file) {
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          ccFrontalPicture: file,
        ),
      ),
    );
  }

  void addBackIdFile(File file) {
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          ccBackPicture: file,
        ),
      ),
    );
  }

  void addSelfieFile(File file) {
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          selfiePicture: file,
        ),
      ),
    );
  }

  void isLoading(bool isLoading) {
    emit(
      state.copyWith(
        isLoading: isLoading,
      ),
    );
  }

  void setError(String error) {
    emit(
      state.copyWith(error: error),
    );
  }

  void setReferences(
    LoanReferenceEntity firstReference,
    LoanReferenceEntity secondReference,
  ) {
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          firstReference: firstReference,
          secondReference: secondReference,
        ),
      ),
    );
  }

  void setBankAccount(
    LoanBankAccountEntity bankAccount,
  ) {
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          bankInformation: bankAccount,
        ),
      ),
    );
  }

  Future<void> getLoans() async {
    isLoading(true);
    final response = await _getLoansUseCase.call(
      phone: sl<AuthCubit>(instanceName: 'auth').state.user.phone,
    );

    response.fold(
      (error) => setError(error.toString()),
      (loans) {
        setLoans(loans);
      },
    );
    isLoading(false);
  }

  void setLoans(List<LoanRequestEntity> loans) {
    emit(
      state.copyWith(
        loans: loans,
      ),
    );
  }

  Future<void> updateUserSubscription() async {
    isLoading(true);
    final response = await _updateUserSubscriptionUseCase.call(
      email: sl<AuthCubit>(instanceName: 'auth').state.user.email,
    );

    response.fold(
      (error) => setError(error.toString()),
      (loans) {
        final auth = sl<AuthCubit>(instanceName: 'auth');
        auth.login(
          user: auth.state.user.copyWith(isSubscribed: true),
        );
      },
    );
    isLoading(false);
  }

  Future<bool> updateLoanInstallments(LoanRequestEntity loan) async {
    final response = await _updateLoanUseCase.call(
      loan: loan,
    );
    return response.fold(
      (error) {
        setError(error.toString());
        return false;
      },
      (status) {
        return status;
      },
    );
  }

  Future<void> submitLoan(BuildContext context) async {
    isLoading(true);
    final response = await _createLoanUseCase.call(
      interest: state.limits.interest,
      loan: state.loanInformation,
      paymentPeriod: state.paymentPeriod,
      selectedInstallments: state.selectedInstallments,
      totalLoanAmount: state.totalLoanAmount,
      phone: sl<AuthCubit>(instanceName: 'auth').state.user.phone,
    );

    response.fold(
      (error) => setError(error.toString()),
      (limits) {
        context.pop();
        context.pop();
        emit(
          state.copyWith(
            loanInformation: LoanInformationEntity.initial(),
            totalLoanAmount: 30000,
            selectedInstallments: 4,
            paymentPeriod: 'Quincenal',
          ),
        );
        ModalbottomsheetUtils.successBottomSheet(context, 'Solicitud Enviada',
            'Tu solicitud ha sido enviada con éxito', 'Aceptar', null);
      },
    );
    isLoading(false);
  }

  void updateLoan(int loanIndex) {
    final loan = state.loans[loanIndex].copyWith(
      installmentsPaid: state.loans[loanIndex].installmentsPaid + 1,
    );

    if (loanIndex != -1) {
      emit(
        state.copyWith(
          loans: [
            ...state.loans.sublist(0, loanIndex), // Elementos antes del índice
            loan, // El préstamo actualizado
            ...state.loans
                .sublist(loanIndex + 1), // Elementos después del índice
          ],
        ),
      );
    }
  }

  void clear() {
    emit(
      HomeState(
        loans: [],
        loanInformation: LoanInformationEntity.initial(),
        limits: LimitModel(
          selectedSegment: 25,
          minAmmount: 10000,
          maxAmmount: 50000,
          maxInstallments: 8,
          interest: 10.0,
        ),
        totalLoanAmount: 30000,
        selectedInstallments: 4,
        paymentPeriod: 'Quincenal',
      ),
    );
  }
}
