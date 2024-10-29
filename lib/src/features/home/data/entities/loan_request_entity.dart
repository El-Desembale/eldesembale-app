import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRequestEntity {
  final double amount;
  final Timestamp createdAt;
  final int installments;
  final double interest;
  final String paymentPeriod;
  final String status;
  LoanRequestEntity({
    required this.amount,
    required this.createdAt,
    required this.installments,
    required this.interest,
    required this.paymentPeriod,
    required this.status,
  });

  factory LoanRequestEntity.fromMap(Map<String, dynamic> map) {
    return LoanRequestEntity(
      amount: map['amount'],
      createdAt: map['created_at'],
      installments: map['installments'],
      interest: map['interest'],
      paymentPeriod: map['payment_period'],
      status: map['status'],
    );
  }
}
