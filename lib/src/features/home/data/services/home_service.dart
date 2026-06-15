import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

import '../../domain/loan_calc.dart';
import '../../domain/models/limit_model.dart';
import '../entities/loan_information_entity.dart';
import '../entities/loan_request_entity.dart';

abstract class HomeService {
  Future<LimitModel> getLimits();
  Future<bool> createLoan({
    required int selectedInstallments,
    required double interest,
    required double totalLoanAmount,
    required String paymentPeriod,
    required String phone,
    required LoanInformationEntity loan,
    String? clientName,
  });
  Future<List<LoanRequestEntity>> getLoans({
    required String phone,
  });
  Future<bool> updateUserSubscription({
    required String email,
  });
  Future<bool> updateLoan({
    required LoanRequestEntity loan,
    int installmentsToPay = 1,
  });
  Future<bool> savePaymentRecord({
    required String transactionId,
    required String reference,
    required String type,
    required String status,
    required int amountInCents,
    required int wompiFee,
    required String userPhone,
    required String userEmail,
    required String userName,
    String source = 'wompi',
    String? loanId,
    int? installmentNumber,
    int? installmentsToPay,
    String? proofUrl,
    String? proofName,
    String? proofContentType,
  });
}

class HomeServiceImpl implements HomeService {
  final FirebaseFirestore _database;
  HomeServiceImpl(
    this._database,
  );

  String get _adminAppUrl {
    final configured = dotenv.env['ADMIN_APP_URL']?.trim() ?? '';
    if (configured.isNotEmpty) {
      return configured;
    }
    return 'https://eldesembale-admin.vercel.app';
  }

  Future<bool> _isUserSubscribed({
    required String phone,
    String? email,
  }) async {
    final matched = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    final normalizedPhone = phone.replaceAll(' ', '');
    final fullPhone = '+57$normalizedPhone';

    Future<void> collect(String field, String value) async {
      if (value.isEmpty) return;
      final snap = await _database.collection('users').where(field, isEqualTo: value).get();
      for (final doc in snap.docs) {
        matched[doc.id] = doc;
      }
    }

    await collect('phone', phone);
    await collect('phone', normalizedPhone);
    await collect('phone', fullPhone);
    if ((email ?? '').isNotEmpty) {
      await collect('email', email!.trim().toLowerCase());
      await collect('email', email.trim());
    }

    return matched.values.any((doc) => doc.data()['isSubscribed'] == true);
  }

  @override
  Future<LimitModel> getLimits() async {
    QuerySnapshot querySnapshot =
        await _database.collection('app_config').get();

    // Calculate available budget
    double? budgetAvailable;
    try {
      final budgetDoc =
          await _database.collection('settings').doc('budget').get();
      if (budgetDoc.exists) {
        final budgetData = budgetDoc.data() as Map<String, dynamic>;
        final totalCapital =
            (budgetData['total_capital'] as num?)?.toDouble() ?? 0;
        if (totalCapital > 0) {
          final loansSnap = await _database
              .collection('loan_request')
              .where('status', whereIn: ['approved', 'disbursed'])
              .get();
          double capitalLent = 0;
          double capitalRecovered = 0;
          for (final doc in loansSnap.docs) {
            final d = doc.data();
            final amount = (d['amount'] as num?)?.toDouble() ?? 0;
            final installments = (d['installments'] as num?)?.toInt() ?? 0;
            final installmentsPaid =
                (d['installments_paid'] as num?)?.toInt() ?? 0;
            capitalLent += amount;
            if (installments > 0) {
              capitalRecovered += installmentsPaid * (amount / installments);
            }
          }
          budgetAvailable = totalCapital - capitalLent + capitalRecovered;
        }
      }
    } catch (_) {}

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return LimitModel(
        maxAmmount: data['max_amount'],
        minAmmount: data['min_amount'],
        maxInstallments: data['number_max_of_installments'],
        minInstallments: data['number_min_of_installments'],
        interest: data['interest'] * 1.0,
        selectedSegment: 25,
        budgetAvailable: budgetAvailable,
      );
    } else {
      return LimitModel(
        maxAmmount: 50000,
        minAmmount: 10000,
        maxInstallments: 8,
        minInstallments: 2,
        selectedSegment: 25,
        interest: 10.0,
        budgetAvailable: budgetAvailable,
      );
    }
  }

  // Lee los parámetros configurables del pricing (config/loan_pricing y config/wompi).
  // Cae a los defaults del motor si los docs no existen o están incompletos.
  Future<LoanPricingConfig> _getPricingConfig() async {
    var cfg = kDefaultPricingConfig;
    try {
      final results = await Future.wait([
        _database.collection('config').doc('loan_pricing').get(),
        _database.collection('config').doc('wompi').get(),
      ]);
      final pricingDoc = results[0];
      final wompiDoc = results[1];

      double interesMensual = cfg.interesMensual;
      PricingSplit split = cfg.split;
      WompiFees wompi = cfg.wompi;

      double pick(dynamic v, double fallback) =>
          (v is num) ? v.toDouble() : fallback;

      if (pricingDoc.exists) {
        final d = pricingDoc.data() as Map<String, dynamic>;
        final s = (d['split'] as Map<String, dynamic>?) ?? {};
        interesMensual = pick(d['interes_mensual'], cfg.interesMensual);
        split = PricingSplit(
          interes: pick(s['interes'], cfg.split.interes),
          plataforma: pick(s['plataforma'], cfg.split.plataforma),
          administrativo: pick(s['administrativo'], cfg.split.administrativo),
        );
      }
      if (wompiDoc.exists) {
        final d = wompiDoc.data() as Map<String, dynamic>;
        wompi = WompiFees(
          porcentaje: pick(d['porcentaje'], cfg.wompi.porcentaje),
          fijo: pick(d['fijo'], cfg.wompi.fijo),
          iva: pick(d['iva'], cfg.wompi.iva),
        );
      }
      cfg = LoanPricingConfig(
        interesMensual: interesMensual,
        split: split,
        wompi: wompi,
      );
    } catch (_) {}
    return cfg;
  }

  @override
  Future<bool> createLoan({
    required int selectedInstallments,
    required double interest,
    required double totalLoanAmount,
    required String paymentPeriod,
    required String phone,
    required LoanInformationEntity loan,
    String? clientName,
  }) async {
    try {
      final subscribed = await _isUserSubscribed(phone: phone);
      if (!subscribed) {
        throw Exception('SUBSCRIPTION_REQUIRED');
      }
      final ccFrontalPicture = loan.ccFrontalPicture.path.isNotEmpty
          ? await uploadImage(loan.ccFrontalPicture, 'cc_frontal_picture')
          : loan.existingCcFrontalPictureUrl;
      final ccBackPicture = loan.ccBackPicture.path.isNotEmpty
          ? await uploadImage(loan.ccBackPicture, 'cc_back_picture')
          : loan.existingCcBackPictureUrl;
      final selfiePicture = loan.selfiePicture.path.isNotEmpty
          ? await uploadImage(loan.selfiePicture, 'selfie_picture')
          : loan.existingSelfiePictureUrl;
      final empInvoiceFile = loan.empInvoiceFile.path.isNotEmpty
          ? await uploadPDF(loan.empInvoiceFile, 'emp_invoice_file')
          : loan.existingEmpInvoiceUrl;

      Map<String, dynamic> loanInformation = loan.toJson();
      loanInformation['emp_invoice_file'] = empInvoiceFile;
      loanInformation['cc_frontal_picture'] = ccFrontalPicture;
      loanInformation['cc_back_picture'] = ccBackPicture;
      loanInformation['selfie_picture'] = selfiePicture;
      var uuid = const Uuid();

      String generatedId = uuid.v4();

      // Desglose del crédito (capital + interés/plataforma/administrativo + Wompi por cuota),
      // calculado y guardado al crear (snapshot de tarifas) para no recalcular histórico.
      final createdAt = DateTime.now();
      final pricingConfig = await _getPricingConfig();
      final pricing = computeLoanPricing(
        capital: totalLoanAmount,
        numeroCuotas: selectedInstallments,
        paymentPeriod: paymentPeriod,
        fechaDesembolso: createdAt,
        config: pricingConfig,
      );

      await _database.collection('loan_request').doc(generatedId).set({
        'id': generatedId,
        'amount': totalLoanAmount,
        'phone': phone,
        'installments': selectedInstallments,
        'interest': interest,
        'payment_period': paymentPeriod,
        'installments_paid': 0,
        'status': 'pending',
        'created_at': createdAt,
        'loan_information': loanInformation,
        'pricing': pricing.toMap(),
      });

      // Notificar al admin por WhatsApp
      try {
        await Dio().post(
          '$_adminAppUrl/api/notify-new-loan',
          data: {
            'loanId': generatedId,
            'amount': totalLoanAmount,
            'phone': phone,
            'installments': selectedInstallments,
            'paymentPeriod': paymentPeriod,
            'interest': interest,
            'createdAt': createdAt.toIso8601String(),
            'installmentAmounts':
                pricing.installments.map((c) => c.totalCliente).toList(),
            'totalCliente': pricing.totalCliente,
            if (clientName != null && clientName.isNotEmpty)
              'clientName': clientName,
          },
        );
      } catch (_) {
        // La notificación es best-effort, no bloquea el flujo
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<LoanRequestEntity>> getLoans({required String phone}) async {
    QuerySnapshot querySnapshot = await _database
        .collection('loan_request')
        .where('phone', isEqualTo: phone)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<LoanRequestEntity> loans = [];
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        final data = querySnapshot.docs[i].data() as Map<String, dynamic>;
        loans.add(LoanRequestEntity.fromMap(data));
      }
      loans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return loans;
    } else {
      return [];
    }
  }

  @override
  Future<bool> updateUserSubscription({
    required String email,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _database
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({'isSubscribed': true});
        }
      } else {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateLoan({
    required LoanRequestEntity loan,
    int installmentsToPay = 1,
  }) async {
    QuerySnapshot querySnapshot = await _database
        .collection('loan_request')
        .where('id', isEqualTo: loan.id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        await doc.reference.update(
          {'installments_paid': loan.installmentsPaid + installmentsToPay},
        );
      }
    } else {
      return false;
    }
    return true;
  }

  @override
  Future<bool> savePaymentRecord({
    required String transactionId,
    required String reference,
    required String type,
    required String status,
    required int amountInCents,
    required int wompiFee,
    required String userPhone,
    required String userEmail,
    required String userName,
    String source = 'wompi',
    String? loanId,
    int? installmentNumber,
    int? installmentsToPay,
    String? proofUrl,
    String? proofName,
    String? proofContentType,
  }) async {
    try {
      // Campos financieros estándar: bruto pagado, comisión Wompi y neto recibido.
      final grossAmount = amountInCents / 100;
      final fee = wompiFee < 0 ? 0 : wompiFee;
      await _database.collection('payments').doc(transactionId).set({
        'id': transactionId,
        'reference': reference,
        'type': type,
        'source': source,
        'status': status,
        'amount': grossAmount,
        'amount_in_cents': amountInCents,
        'gross_amount': grossAmount,
        'wompi_fee': fee,
        'net_amount': grossAmount - fee,
        'currency': 'COP',
        'user_phone': userPhone,
        'user_email': userEmail,
        'user_name': userName,
        'loan_id': loanId,
        'installment_number': installmentNumber,
        'installments_to_pay': installmentsToPay,
        'proof_url': proofUrl,
        'proof_name': proofName,
        'proof_content_type': proofContentType,
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving payment record: $e');
      return false;
    }
  }
}

Future<String> uploadPaymentProof(File file, String prefix) async {
  try {
    final extension = file.path.split('.').last.toLowerCase();
    final reference = FirebaseStorage.instance.ref().child(
      'payment_proofs/${DateTime.now().millisecondsSinceEpoch}_$prefix.$extension',
    );
    final uploadTask = reference.putFile(file);
    await uploadTask;
    return await reference.getDownloadURL();
  } catch (e) {
    debugPrint('Error uploading payment proof: $e');
    return '';
  }
}

Future<String> uploadImage(File file, String prefix) async {
  try {
    // Obtén una referencia al almacenamiento de Firebase
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('uploads/${DateTime.now().millisecondsSinceEpoch}_$prefix.png');

    // Sube el archivo
    UploadTask uploadTask = reference.putFile(file);
    await uploadTask;

    // Obtén la URL de descarga
    String downloadUrl = await reference.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    return '';
  }
}

Future<String> uploadPDF(File file, String prefix) async {
  try {
    // Obtén una referencia al almacenamiento de Firebase
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('uploads/${DateTime.now().millisecondsSinceEpoch}_$prefix.pdf');

    // Sube el archivo
    UploadTask uploadTask = reference.putFile(file);
    await uploadTask;

    // Obtén la URL de descarga
    String downloadUrl = await reference.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    debugPrint('Error uploading PDF: $e');
    return '';
  }
}
