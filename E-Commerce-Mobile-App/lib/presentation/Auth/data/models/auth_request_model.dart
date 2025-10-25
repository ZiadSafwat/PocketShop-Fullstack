class AuthRequestModel {
  final String email;
  final String password;

  AuthRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'identity': email,
    'password': password,
  };
}