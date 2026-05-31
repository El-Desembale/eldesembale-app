import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.email,
    required super.phone,
    required super.name,
    required super.lastName,
    required super.isSubscribed,
    super.riskProfile,
    super.maxLoanAmount,
    super.isBlockedForNewLoans,
  });
  static UserModel initial() => UserModel(
        name: "",
        lastName: "",
        phone: "",
        email: "",
        isSubscribed: false,
      );
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json["email"],
        phone: json["phone"],
        name: json["name"],
        lastName: json["last_name"],
        isSubscribed: json["isSubscribed"] ?? false,
        riskProfile: json["riskProfile"] ?? 'NEW',
        maxLoanAmount: (json["maxLoanAmount"] as num?)?.toInt() ?? 100000,
        isBlockedForNewLoans: json["isBlockedForNewLoans"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "phone": phone,
        "name": name,
        "last_name": lastName,
        "isSubscribed": isSubscribed,
        "riskProfile": riskProfile,
        "maxLoanAmount": maxLoanAmount,
        "isBlockedForNewLoans": isBlockedForNewLoans,
      };

  UserModel copyWith({
    String? email,
    String? phone,
    String? name,
    String? lastName,
    bool? isSubscribed,
    String? riskProfile,
    int? maxLoanAmount,
    bool? isBlockedForNewLoans,
  }) {
    return UserModel(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      riskProfile: riskProfile ?? this.riskProfile,
      maxLoanAmount: maxLoanAmount ?? this.maxLoanAmount,
      isBlockedForNewLoans: isBlockedForNewLoans ?? this.isBlockedForNewLoans,
    );
  }
}
