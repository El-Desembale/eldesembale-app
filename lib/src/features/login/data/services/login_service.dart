import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<String> sendOtpVerification({
    required String countryCode,
    required String phone,
  });
  Future<bool> verifyOtp({
    required String verificationId,
    required String otp,
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
        'countryCode': countryCode,
        'documentType': documentType,
        'documentNumber': documentNumberm,
        'password': password,
      });

      return UserModel(
        email: email,
        phone: user,
        lastName: lastName,
        name: name,
      );
    } catch (e) {
      throw Exception("Ha ocurrido un error inesperado.");
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
        return UserModel(
          email: doc['email'] ?? "",
          phone: user,
          lastName: doc['lastName'] ?? "",
          name: doc['name'] ?? "",
        );
      } else {
        throw Exception("Usuario o contraseña incorrecta.");
      }
    } catch (e) {
      throw Exception("Ha ocurrido un error inesperado.");
    }
  }

  @override
  Future<String> sendOtpVerification({
    required String phone,
    required String countryCode,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final Completer<String> completer =
        Completer<String>(); // Inicializar el Completer

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: "$countryCode$phone",
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Aquí el OTP se completa automáticamente
          final verificationId = credential.verificationId ?? "";
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
      );

      return await completer.future;
    } catch (e) {
      debugPrint('Error enviando OTP: $e');
      return ""; // Hubo un error al enviar el OTP
    }
  }

  @override
  Future<bool> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      // Crear las credenciales con el verificationId y el código OTP ingresado
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Iniciar sesión con las credenciales
      final response = await auth.signInWithCredential(credential);
      if (response.user != null) {
        debugPrint("OTP verificado correctamente");
        return true;
      } else {
        return false;
      }
      // Si la autenticación es exitosa
    } on OSError {
      return false;
    } catch (e) {
      // Si ocurre algún error en la verificación
      debugPrint('Error verificando OTP: $e');
      return false;
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
