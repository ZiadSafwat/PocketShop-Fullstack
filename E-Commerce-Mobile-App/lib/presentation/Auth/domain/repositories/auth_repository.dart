import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/login_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginEntity>> login(String email, String password);
  Future<Either<Failure, LoginEntity>> authChecker( );
  Future<Either<Failure, bool>> logout( );
 }