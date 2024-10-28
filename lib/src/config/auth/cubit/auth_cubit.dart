// ignore_for_file: use_build_context_synchronously

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../core/preferences/shared_preference.dart';
import '../data/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final LocalSharedPreferences _prefs;

  AuthCubit(
    this._prefs,
  ) : super(
          AuthState(
            status: AuthStatus.notLogged,
            token: '',
            user: UserModel.initial(),
          ),
        );

  Future<void> login({
    required UserModel user,
    required BuildContext context,
  }) async {
    _prefs.isLogged = true;
    emit(
      state.copyWith(
        status: AuthStatus.logged,
        user: user,
      ),
    );
  }

  Future<void> logout() async {
    emit(
      state.copyWith(
        status: AuthStatus.notLogged,
        token: '',
        user: UserModel.initial(),
      ),
    );
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return {
      'status': state.status.toJson(),
      'token': state.token,
      'user': state.user.toJson(),
    };
  }

  @override
  AuthState? fromJson(
    Map<String, dynamic> json,
  ) {
    return AuthState(
      status: AuthStatus.fromJson(
        json['status'],
      ),
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user']),
    );
  }
}
