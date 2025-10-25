import '../../domain/entities/login_entity.dart';

class LoginResponseModel {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final bool verified;
  final String token;
  final String role;

  LoginResponseModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.verified,
    required this.token,
    required this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final record = json['record'] ;
    return LoginResponseModel(
      id: record['id'] as String,
      username: record['username'] as String,
      email: record['email'] as String,
      avatar: record['avatar'] as String,
      verified: record['verified'] as bool,
      token: json['token'] as String,
      role: record['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record':{
        'id': id,
        'username': username,
        'email': email,
        'avatar': avatar,
        'verified': verified,

        'role': role
      },  'token': token
    };
  }

  LoginEntity toEntity() => LoginEntity(
    id: id,
    username: username,
    email: email,
    avatar: avatar,
    verified: verified,
    token: token, role: role,
  );
}
