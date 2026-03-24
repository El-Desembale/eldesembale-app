import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../config/auth/data/models/user_model.dart';

abstract class LoginService {
  Future<bool> validatePhone({
    required String phone,
  });
  Future<UserModel> login({
    required String user,
    required String password,
    required BuildContext context,
  });
  Future<UserModel> register({
    required String user,
    required String name,
    required String lastName,
    required String email,
    required String documentType,
    required String documentNumberm,
    required String password,
    required String countryCode,
    required BuildContext context,
  });
  Future<bool> sendEmailOtp({
    required String email,
  });
  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  });
  Future<String?> getEmailByPhone({
    required String phone,
  });
  Future<bool> newPassword({
    required String phone,
    required String password,
  });
}

class LoginServiceImpl implements LoginService {
  final FirebaseFirestore _database;
  LoginServiceImpl(
    this._database,
  );

  @override
  Future<bool> validatePhone({
    required String phone,
  }) async {
    try {
      final QuerySnapshot userQuery = await _database
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("Ha ocurrido un error inesperado.");
    }
  }

  @override
  Future<UserModel> register({
    required String user,
    required String name,
    required String lastName,
    required String email,
    required String documentType,
    required String documentNumberm,
    required String password,
    required String countryCode,
    required BuildContext context,
  }) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').add({
        'phone': user,
        'name': name,
        'lastName': lastName,
        'email': email,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'isSubscribed': false,
        'countryCode': countryCode,
        'documentType': documentType,
        'documentNumber': documentNumberm,
        'password': password,
      });

      // Try to create Firebase Auth session for Storage uploads (non-blocking)
      try {
        final auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          await auth.signInAnonymously();
        }
      } catch (_) {
        // Anonymous auth may not be enabled, don't block registration
      }

      return UserModel(
        email: email,
        phone: user,
        lastName: lastName,
        name: name,
        isSubscribed: false,
      );
    } catch (e) {
      debugPrint('Register service error: $e');
      throw Exception("Ha ocurrido un error inesperado: $e");
    }
  }

  @override
  Future<UserModel> login({
    required String user,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final QuerySnapshot userQuery = await _database
          .collection('users')
          .where('phone', isEqualTo: user)
          .where('password', isEqualTo: password)
          .get();
      if (userQuery.docs.isNotEmpty) {
        final doc = userQuery.docs.first.data() as Map<String, dynamic>;
        // Try Firebase Auth session for Storage uploads (non-blocking)
        try {
          final auth = FirebaseAuth.instance;
          if (auth.currentUser == null) {
            await auth.signInAnonymously();
          }
        } catch (_) {}
        return UserModel(
          email: doc['email'] ?? "",
          phone: user,
          lastName: doc['lastName'] ?? "",
          name: doc['name'] ?? "",
          isSubscribed: doc['isSubscribed'] ?? false,
        );
      } else {
        throw Exception("Usuario o contraseña incorrecta.");
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> sendEmailOtp({
    required String email,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('sendOtpEmail');
      final result = await callable.call({'email': email});
      return result.data['success'] == true;
    } catch (e) {
      debugPrint('Error enviando OTP por email: $e');
      return false;
    }
  }

  @override
  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final querySnapshot = await _database
          .collection('otp_codes')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .where('code', isEqualTo: otp)
          .where('used', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      await doc.reference.update({'used': true});
      return true;
    } catch (e) {
      debugPrint('Error verificando OTP: $e');
      return false;
    }
  }

  @override
  Future<String?> getEmailByPhone({
    required String phone,
  }) async {
    try {
      final querySnapshot = await _database
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return data['email'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo email: $e');
      return null;
    }
  }

  @override
  Future<bool> newPassword({
    required String phone,
    required String password,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();

    // Verificar si se encontró el documento
    if (querySnapshot.docs.isNotEmpty) {
      // Actualizar la contraseña en Firestore
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      await firestore.collection('users').doc(userDoc.id).update({
        'password': password,
      });

      return true;
    } else {
      return false;
    }
  }
}
