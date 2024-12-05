class UserEntity {
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final bool isSubscribed;

  UserEntity({
    required this.email,
    required this.phone,
    required this.name,
    required this.lastName,
    required this.isSubscribed,
  });
}
