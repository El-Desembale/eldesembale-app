// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_cubit.dart';

enum AuthStatus {
  notLogged,
  logged;

  String toJson() => name;
  static AuthStatus fromJson(String json) => values.byName(json);
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String token;
  final UserModel user;

  const AuthState({
    required this.status,
    required this.token,
    required this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        status,
        token,
        user,
      ];

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      status: AuthStatus.fromJson(json['status']),
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
      'token': token,
      'user': user.toJson(),
    };
  }
}
