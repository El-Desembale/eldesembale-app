import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
  });
  Future<List<LoanRequestEntity>> getLoans({
    required String phone,
  });
}

class HomeServiceImpl implements HomeService {
  final FirebaseFirestore _database;
  HomeServiceImpl(
    this._database,
  );

  @override
  Future<LimitModel> getLimits() async {
    QuerySnapshot querySnapshot =
        await _database.collection('app_config').get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return LimitModel(
        maxAmmount: data['max_amount'],
        minAmmount: data['min_amount'],
        maxInstallments: data['number_max_of_installments'],
        interest: data['interest'] * 1.0,
        selectedSegment: 25,
      );
    } else {
      return LimitModel(
        maxAmmount: 50000,
        minAmmount: 10000,
        maxInstallments: 8,
        selectedSegment: 25,
        interest: 10.0,
      );
    }
  }

  @override
  Future<bool> createLoan({
    required int selectedInstallments,
    required double interest,
    required double totalLoanAmount,
    required String paymentPeriod,
    required String phone,
    required LoanInformationEntity loan,
  }) async {
    try {
      final ccFrontalPicture =
          await uploadImage(loan.ccFrontalPicture, 'cc_frontal_picture');
      final ccBackPicture =
          await uploadImage(loan.ccBackPicture, 'cc_back_picture');
      final selfiePicture =
          await uploadImage(loan.selfiePicture, 'selfie_picture');
      final empInvoiceFile =
          await uploadPDF(loan.empInvoiceFile, 'emp_invoice_file');

      Map<String, dynamic> loanInformation = loan.toJson();
      loanInformation['emp_invoice_file'] = empInvoiceFile;
      loanInformation['cc_frontal_picture'] = ccFrontalPicture;
      loanInformation['cc_back_picture'] = ccBackPicture;
      loanInformation['selfie_picture'] = selfiePicture;

      await _database.collection('loan_request').add({
        'amount': totalLoanAmount,
        'phone': phone,
        'installments': selectedInstallments,
        'interest': interest,
        'payment_period': paymentPeriod,
        'status': 'pending',
        'created_at': DateTime.now(),
        'loan_information': loanInformation,
      });
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
      return loans;
    } else {
      return [];
    }
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
