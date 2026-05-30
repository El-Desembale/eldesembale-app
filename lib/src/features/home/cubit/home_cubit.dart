// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
import '../domain/use_case/save_payment_record_use_case.dart';
import '../domain/use_case/update_user_subscription_use_case.dart';

part 'home_state.dart';

class PaymentData {
  final String url;
  final String reference;
  final int amountInCents;
  PaymentData({
    required this.url,
    required this.reference,
    required this.amountInCents,
  });
}

class HomeCubit extends Cubit<HomeState> {
  final GetLimitsUseCase _getLimitsCase;
  final CreateLoanUseCase _createLoanUseCase;
  final GetLoansUseCase _getLoansUseCase;
  final UpdateUserSubscriptionUseCase _updateUserSubscriptionUseCase;
  final UpdateLoanUseCase _updateLoanUseCase;
  final SavePaymentRecordUseCase _savePaymentRecordUseCase;
  HomeCubit(
    this._getLimitsCase,
    this._createLoanUseCase,
    this._getLoansUseCase,
    this._updateUserSubscriptionUseCase,
    this._updateLoanUseCase,
    this._savePaymentRecordUseCase,
  ) : super(
          HomeState(
            loanInformation: LoanInformationEntity.initial(),
            limits: LimitModel(
              selectedSegment: 25,
              minAmmount: 50000,
              maxAmmount: 1000000,
              maxInstallments: 8,
              minInstallments: 2,
              interest: 1.1,
            ),
            loans: [],
            selectedInstallments: 4,
            totalLoanAmount: 250000,
            paymentPeriod: 'Quincenal',
            subscriptionAmount: 22000,
            reusableLoanInformation: null,
          ),
        );

  void clearError() {
    emit(
      state.copyWith(error: null),
    );
  }

  void updateSegmentFromPosition(BuildContext context, double dx) {
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final newSegment = (dx / width * 55).clamp(0, 49).toInt();
    updateSelectedSegment(newSegment);
  }

  int _parseSubscriptionAmount(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 22000;
    }
    return 22000;
  }

  Future<Map<String, dynamic>> _getWompiConfig() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('config')
          .doc('wompi')
          .get();
      if (snap.exists) {
        final data = snap.data()!;
        return {
          'publicKey': data['publicKey'] ?? '',
          'integrityKey': data['integrityKey'] ?? '',
          'subscriptionAmount': _parseSubscriptionAmount(
            data['subscriptionAmount'],
          ),
        };
      }
    } catch (_) {}
    return {
      'publicKey': '',
      'integrityKey': '',
      'subscriptionAmount': 22000,
    };
  }

  Future<void> loadWompiConfig() async {
    final wompi = await _getWompiConfig();
    emit(
      state.copyWith(
        subscriptionAmount: wompi['subscriptionAmount'] as int,
      ),
    );
  }

  Future<void> loadReusableLoanInformation() async {
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    if (user.phone.isEmpty) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('loan_request')
          .where('phone', isEqualTo: user.phone)
          .get();

      if (snap.docs.isEmpty) {
        emit(state.copyWith(reusableLoanInformation: null));
        return;
      }

      final docs = [...snap.docs]..sort((a, b) {
          final aDate = (a.data()['created_at'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = (b.data()['created_at'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

      final rawLoanInformation =
          (docs.first.data()['loan_information'] as Map<String, dynamic>?) ??
              {};
      final reusable = LoanInformationEntity.fromStoredMap(rawLoanInformation);

      emit(
        state.copyWith(
          reusableLoanInformation:
              reusable.hasReusableProfile ? reusable : null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(reusableLoanInformation: null));
    }
  }

  void useReusableLoanInformation() {
    final reusable = state.reusableLoanInformation;
    if (reusable == null) return;
    emit(state.copyWith(loanInformation: reusable));
  }

  void resetLoanInformation() {
    emit(state.copyWith(loanInformation: LoanInformationEntity.initial()));
  }

  Future<PaymentData> generateSubscriptionPayment(BuildContext context) async {
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    final wompi = await _getWompiConfig();
    final priv_key = wompi['integrityKey']!;
    final public_key = wompi['publicKey']!;
    final subAmount = wompi['subscriptionAmount'] as int;
    final amountInCents = subAmount * 100;
    emit(state.copyWith(subscriptionAmount: subAmount));

    final reference =
        'subscription${user.phone}${DateTime.now().millisecondsSinceEpoch}';

    final integrity = _generateIntegrityHash(
      reference,
      amountInCents.toString(),
      priv_key,
    );
    final url = generateUrl(
      public_key,
      amountInCents,
      reference,
      integrity,
      user.email,
      '${user.name} ${user.lastName}',
      user.phone,
    );

    return PaymentData(
      url: url,
      reference: reference,
      amountInCents: amountInCents,
    );
  }

  Future<PaymentData> generatePayment(
    BuildContext context,
    int amountInCents,
  ) async {
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    final wompi = await _getWompiConfig();
    final priv_key = wompi['integrityKey']!;
    final public_key = wompi['publicKey']!;

    amountInCents = amountInCents * 100;

    final reference =
        'payment${user.phone}${DateTime.now().millisecondsSinceEpoch}';

    final integrity = _generateIntegrityHash(
      reference,
      amountInCents.toString(),
      priv_key,
    );
    final url = generateUrl(
      public_key,
      amountInCents,
      reference,
      integrity,
      user.email,
      '${user.name} ${user.lastName}',
      user.phone,
    );

    return PaymentData(
      url: url,
      reference: reference,
      amountInCents: amountInCents,
    );
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

  void updateAmountDirectly(double amount) {
    final min = state.limits.minAmmount.toDouble();
    final max = state.limits.maxAmmount.toDouble();
    final clamped = amount.clamp(min, max);
    final segment = ((clamped - min) / (max - min) * 49).round().clamp(0, 49);
    emit(state.copyWith(
      limits: state.limits.copyWith(selectedSegment: segment),
      totalLoanAmount: clamped,
    ));
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
    await _refreshUserRiskAndCap();
    isLoading(false);
  }

  // Lee el perfil de riesgo/cupo fresco desde Firestore y topa el monto máximo
  Future<void> _refreshUserRiskAndCap() async {
    try {
      final phone = sl<AuthCubit>(instanceName: 'auth').state.user.phone;
      if (phone.isEmpty) return;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return;
      final d = snap.docs.first.data();
      final maxLoan = (d['maxLoanAmount'] as num?)?.toInt() ?? 200000;
      final blocked = d['isBlockedForNewLoans'] ?? false;
      final riskProfile = d['riskProfile'] ?? 'NEW';

      // Topa el monto máximo del slider al cupo del usuario
      final effectiveMax =
          state.limits.maxAmmount > maxLoan ? maxLoan : state.limits.maxAmmount;
      final cappedLimits = state.limits.copyWith(maxAmmount: effectiveMax);
      // El monto por defecto se ajusta al cupo del perfil:
      // - si el usuario aún no ha tocado el monto (valor genérico inicial), o
      // - si el monto seleccionado excede el cupo
      const genericDefault = 250000.0;
      final isAtGenericDefault = state.totalLoanAmount == genericDefault;
      final adjustedTotal =
          (isAtGenericDefault || state.totalLoanAmount > effectiveMax)
              ? effectiveMax.toDouble()
              : state.totalLoanAmount;

      emit(state.copyWith(
        limits: cappedLimits,
        totalLoanAmount: adjustedTotal,
        riskProfile: riskProfile,
        maxLoanAmount: maxLoan,
        isBlockedForNewLoans: blocked,
      ));
    } catch (_) {}
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

  void updateDirectionParts({
    required String wayType,
    required String wayNumber,
    required String wayNumber2,
    required String wayNumber3,
    required String interior,
    required String additionalInfo,
    required String city,
  }) {
    final combined =
        "$wayType $wayNumber # $wayNumber2 - $wayNumber3 $interior, $additionalInfo, $city";
    emit(
      state.copyWith(
        loanInformation: state.loanInformation.copyWith(
          direction: combined,
          directionWayType: wayType,
          directionWayNumber: wayNumber,
          directionWayNumber2: wayNumber2,
          directionWayNumber3: wayNumber3,
          directionInterior: interior,
          directionAdditionalInfo: additionalInfo,
          directionCity: city,
        ),
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

  Future<bool> updateLoanInstallments(LoanRequestEntity loan,
      {int installmentsToPay = 1}) async {
    final response = await _updateLoanUseCase.call(
      loan: loan,
      installmentsToPay: installmentsToPay,
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
    // Recalcula riesgo/cupo fresco antes de validar
    await _refreshUserRiskAndCap();

    // Bloqueo por mora grave
    if (state.isBlockedForNewLoans) {
      ModalbottomsheetUtils.customError(
        context,
        'Solicitud no disponible',
        'Presentas mora en un crédito anterior y no puedes solicitar nuevos créditos en este momento.',
      );
      return;
    }

    // Tope de cupo según el perfil de riesgo
    if (state.totalLoanAmount > state.maxLoanAmount) {
      ModalbottomsheetUtils.customError(
        context,
        'Monto sobre el cupo',
        'El monto máximo permitido para tu perfil es \$${NumberFormat('#,##0', 'en_US').format(state.maxLoanAmount)}.',
      );
      return;
    }

    // Block if there's an active (approved/disbursed) loan with unpaid installments
    final activeLoan = state.loans.where((l) => l.isActive).firstOrNull;
    if (activeLoan != null &&
        activeLoan.installments > 0 &&
        activeLoan.installmentsPaid < activeLoan.installments) {
      ModalbottomsheetUtils.customError(
        context,
        'Préstamo activo',
        'Debes pagar todas las cuotas del préstamo activo antes de solicitar uno nuevo.',
      );
      return;
    }
    isLoading(true);
    final authUser = sl<AuthCubit>(instanceName: 'auth').state.user;
    final response = await _createLoanUseCase.call(
      interest: state.limits.interest,
      loan: state.loanInformation,
      paymentPeriod: state.paymentPeriod,
      selectedInstallments: state.selectedInstallments,
      totalLoanAmount: state.totalLoanAmount,
      phone: authUser.phone,
      clientName: '${authUser.name} ${authUser.lastName}'.trim(),
    );

    response.fold(
      (error) => setError(error.toString()),
      (limits) {
        emit(
          state.copyWith(
            loanInformation: LoanInformationEntity.initial(),
            totalLoanAmount: 30000,
            selectedInstallments: 4,
            paymentPeriod: 'Quincenal',
          ),
        );
        getLoans();
        loadReusableLoanInformation();
        ModalbottomsheetUtils.loanSubmittedSheet(context);
      },
    );
    isLoading(false);
  }

  void updateLoan(int loanIndex, {int installmentsToPay = 1}) {
    final loan = state.loans[loanIndex].copyWith(
      installmentsPaid:
          state.loans[loanIndex].installmentsPaid + installmentsToPay,
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

  Future<void> savePaymentRecord({
    required String transactionId,
    required String reference,
    required String status,
    required int amountInCents,
    String? loanId,
    int? installmentNumber,
  }) async {
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    final type =
        reference.startsWith('subscription') ? 'subscription' : 'installment';
    await _savePaymentRecordUseCase.call(
      transactionId: transactionId,
      reference: reference,
      type: type,
      status: status,
      amountInCents: amountInCents,
      userPhone: user.phone,
      userEmail: user.email,
      userName: '${user.name} ${user.lastName}'.trim(),
      loanId: loanId,
      installmentNumber: installmentNumber,
    );
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
          minInstallments: 1,
          interest: 1.1,
        ),
        totalLoanAmount: 30000,
        selectedInstallments: 4,
        paymentPeriod: 'Quincenal',
        subscriptionAmount: 22000,
        reusableLoanInformation: null,
      ),
    );
  }
}
