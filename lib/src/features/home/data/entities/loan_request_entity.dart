import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/loan_calc.dart';

class LoanRequestEntity {
  final String id;
  final double amount;
  final Timestamp createdAt;
  final Timestamp? disbursedAt;
  final int installments;
  final double interest;
  final String paymentPeriod;
  final String status;
  final int installmentsPaid;
  final String rejectionReason;
  final LoanPricing? pricing;
  LoanRequestEntity({
    required this.id,
    required this.amount,
    required this.createdAt,
    this.disbursedAt,
    required this.installments,
    required this.interest,
    required this.paymentPeriod,
    required this.status,
    required this.installmentsPaid,
    this.rejectionReason = '',
    this.pricing,
  });

  factory LoanRequestEntity.fromMap(Map<String, dynamic> map) {
    return LoanRequestEntity(
      id: map['id'] ?? "",
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      installmentsPaid: (map['installments_paid'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'],
      disbursedAt: map['disbursed_at'] is Timestamp
          ? map['disbursed_at'] as Timestamp
          : null,
      installments: (map['installments'] as num?)?.toInt() ?? 0,
      interest: (map['interest'] as num?)?.toDouble() ?? 0,
      paymentPeriod: map['payment_period'],
      status: map['status'],
      rejectionReason: map['rejection_reason'] ?? '',
      pricing: map['pricing'] is Map
          ? LoanPricing.fromMap(Map<String, dynamic>.from(map['pricing'] as Map))
          : null,
    );
  }
  LoanRequestEntity copyWith({
    String? id,
    double? amount,
    Timestamp? createdAt,
    Timestamp? disbursedAt,
    int? installments,
    double? interest,
    String? paymentPeriod,
    String? status,
    int? installmentsPaid,
    String? rejectionReason,
    LoanPricing? pricing,
  }) {
    return LoanRequestEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      disbursedAt: disbursedAt ?? this.disbursedAt,
      installments: installments ?? this.installments,
      interest: interest ?? this.interest,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      status: status ?? this.status,
      installmentsPaid: installmentsPaid ?? this.installmentsPaid,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      pricing: pricing ?? this.pricing,
    );
  }

  // Un crédito está activo (en proceso de pago) cuando fue aprobado o desembolsado
  bool get isActive => status == 'approved' || status == 'disbursed';
  bool get canPay => isActive && installmentsPaid < installments;

  /// Monto a cobrar de la cuota [index] (0-based): modelo nuevo usa total_cliente.
  int cuotaAmount(int index) {
    final p = pricing;
    if (p != null && index >= 0 && index < p.installments.length) {
      return p.installments[index].totalCliente;
    }
    // Fallback legacy (créditos antiguos sin desglose persistido).
    if (installments <= 0) return 0;
    return ((amount * interest) - amount + (amount / installments)).round();
  }

  /// Suma de [count] cuotas a partir de [fromIdx] (lo que realmente se cobra).
  int sumInstallments(int fromIdx, int count) {
    var s = 0;
    for (var i = 0; i < count; i++) {
      s += cuotaAmount(fromIdx + i);
    }
    return s;
  }

  /// Total que paga el cliente por todo el crédito.
  int get totalClienteAmount => pricing != null
      ? pricing!.totalCliente
      : cuotaAmount(0) * installments;
}
