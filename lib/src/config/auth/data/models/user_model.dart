import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.email,
    required super.phone,
    required super.name,
    required super.lastName,
  });
  static UserModel initial() => UserModel(
        name: "",
        lastName: "",
        phone: "",
        email: "",
      );
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json["email"],
        phone: json["phone"],
        name: json["name"],
        lastName: json["last_name"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "phone": phone,
        "name": name,
        "last_name": lastName,
      };
}
