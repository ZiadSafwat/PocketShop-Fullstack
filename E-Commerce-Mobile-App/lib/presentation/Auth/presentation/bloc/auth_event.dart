import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthCheckEvent extends AuthEvent {


  const AuthCheckEvent( );

  @override
  List<Object> get props => [];
}
class LogoutEvent extends AuthEvent {


  const LogoutEvent(  );

  @override
  List<Object> get props => [ ];
}