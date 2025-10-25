import 'package:dartz/dartz.dart';
import '../../../../core/connection/network_info.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/expentions.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/login_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_request_model.dart';
import '../models/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final NetworkInfo networkInfo;
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.networkInfo,
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, LoginEntity>> login(
      String email, String password) async {
    if (await networkInfo.isConnected!) {
      try {
        final request = AuthRequestModel(email: email, password: password);
        final response =
        LoginResponseModel.fromJson(await remoteDataSource.login(request));

        // Cache data
        await localDataSource.cacheToken(response.token);
        await localDataSource.cacheUser(response);

        return Right(response.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errMessage: e.errorModel.errorMessage,
            statusCode: e.errorModel.status));
      }
    } else {
      return Left(ConnectionFailure(errMessage: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, LoginEntity>> authChecker() async {
    final token = await localDataSource.getToken();

    if (token != null) {
      final isValid = await localDataSource.isTokenValid();
      final isAboutToExpire = await localDataSource.isTokenAboutToExpire();

      if (isValid && !isAboutToExpire) {
        try {
          final response = await localDataSource.getUser();
          return Right(response.toEntity());
        } catch (e) {
          // Fallback to ServerFailure for general local errors
          return Left(ServerFailure(
            errMessage: 'Failed to get user data: $e',
          ));
        }
      } else {
        if (await networkInfo.isConnected!) {
          try {
            final response = await remoteDataSource.refreshToken(token);
            await localDataSource.cacheToken(response.token);
            await localDataSource.cacheUser(response);
            return Right(response.toEntity());
          } on ServerException catch (e) {
            // Check for specific 401 Unauthorized status
            if (e.errorModel.status == 401) {
              await localDataSource.logout();
              return Left(ServerFailure(
                  errMessage: 'Session expired. Please login again.',
                  statusCode: e.errorModel.status));
            }
            return Left(ServerFailure(
                errMessage: e.errorModel.errorMessage,
                statusCode: e.errorModel.status));
          }
        } else {
          return Left(ConnectionFailure(
              errMessage:
              'Cannot refresh token without an internet connection'));
        }
      }
    } else {
      return Left(ConnectionFailure(errMessage: 'User not authenticated'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final response = await localDataSource.logout();
      return Right(response);
    } catch (e) {
      return Left(CacheFailure(errMessage: 'Logout failed'));
    }
  }
}