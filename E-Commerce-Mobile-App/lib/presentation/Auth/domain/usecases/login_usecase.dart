import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/login_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, LoginEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}

class AuthCheckUseCase {
  final AuthRepository repository;

  AuthCheckUseCase(this.repository);

  Future<Either<Failure, LoginEntity>> call( ) {
    return repository.authChecker();
  }
}
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, bool>> call( ) {
    return repository.logout();
  }
}