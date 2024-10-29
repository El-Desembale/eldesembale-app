import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetLimitsUseCase _getLimitsCase;
  final CreateLoanUseCase _createLoanUseCase;
  final GetLoansUseCase _getLoansUseCase;
  HomeCubit(
    this._getLimitsCase,
    this._createLoanUseCase,
    this._getLoansUseCase,
  ) : super(
          HomeState(
            loanInformation: LoanInformationEntity.initial(),
            limits: LimitModel(
              selectedSegment: 25,
              minAmmount: 10000,
              maxAmmount: 50000,
              maxInstallments: 8,
              interest: 10.0,
            ),
            loans: [],
            selectedInstallments: 4,
            totalLoanAmount: 30000,
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
    final newSegment = (dx / box.size.width * 50).clamp(0, 49).toInt();
    updateSelectedSegment(newSegment);
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
    print('Selected segment: $total');
  }

  int calculateDisplayValue() {
    return state.limits.minAmmount +
        ((state.limits.selectedSegment / 49) *
                (state.limits.maxAmmount - state.limits.minAmmount))
            .toInt();
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
