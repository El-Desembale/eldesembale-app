import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRequestEntity {
  final String id;
  final double amount;
  final Timestamp createdAt;
  final int installments;
  final double interest;
  final String paymentPeriod;
  final String status;
  final int installmentsPaid;
  LoanRequestEntity({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.installments,
    required this.interest,
    required this.paymentPeriod,
    required this.status,
    required this.installmentsPaid,
  });

  factory LoanRequestEntity.fromMap(Map<String, dynamic> map) {
    return LoanRequestEntity(
      id: map['id'] ?? "",
      amount: map['amount'],
      installmentsPaid: map['installments_paid'],
      createdAt: map['created_at'],
      installments: map['installments'],
      interest: map['interest'],
      paymentPeriod: map['payment_period'],
      status: map['status'],
    );
  }
  LoanRequestEntity copyWith({
    String? id,
    double? amount,
    Timestamp? createdAt,
    int? installments,
    double? interest,
    String? paymentPeriod,
    String? status,
    int? installmentsPaid,
  }) {
    return LoanRequestEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      installments: installments ?? this.installments,
      interest: interest ?? this.interest,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      status: status ?? this.status,
      installmentsPaid: installmentsPaid ?? this.installmentsPaid,
    );
  }
}
