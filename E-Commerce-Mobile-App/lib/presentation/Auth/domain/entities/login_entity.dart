import 'package:equatable/equatable.dart';
class LoginEntity {
  final String id;
  final String username;
  final String email;
  final String role;
  final String avatar;
  final bool verified;
  final String token;

  LoginEntity({
    required this.id,
    required this.role,
    required this.username,
    required this.email,
    required this.avatar,
    required this.verified,
    required this.token,
  });

  @override
  List<Object> get props => [
    verified,
    username,
    email,
    role,
    token,
  ];
}


