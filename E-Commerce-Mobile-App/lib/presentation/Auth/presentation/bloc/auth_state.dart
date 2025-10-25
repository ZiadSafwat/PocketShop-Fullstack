import 'package:equatable/equatable.dart';
import '../../domain/entities/login_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginEntity loginEntity;

  const AuthSuccess({required this.loginEntity});

  @override
  List<Object> get props => [loginEntity];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class AuthLogout  extends AuthState {
  final bool state;

  const AuthLogout({required this.state});

  @override
  List<Object> get props => [ state];
}