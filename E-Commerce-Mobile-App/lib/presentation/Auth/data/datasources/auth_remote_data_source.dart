// In auth_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:fluttermart/core/databases/api/api_consumer.dart';
import 'package:fluttermart/core/databases/api/end_points.dart';
import '../../../../core/errors/expentions.dart'; // Import your custom exceptions
import '../../../../core/errors/error_model.dart';
import '../models/auth_request_model.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<dynamic> login(AuthRequestModel request);
  Future<LoginResponseModel> refreshToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<dynamic> login(AuthRequestModel request) async {
    try {
      final response = await dio.post(
        EndPoints.login,
        data: request.toJson(),
      );
      return response.data;
    } on DioException catch (e) {
      final errorModel = ErrorModel.fromJson(e.response?.data);
      throw ServerException(errorModel);
    } catch (e) {
      throw ServerException(ErrorModel(
          errorMessage: 'An unexpected error occurred during login',
          status: 500));
    }
  }

  @override
  Future<LoginResponseModel> refreshToken(String token) async {
    try {
      final response = await dio.post(EndPoints.authRefresh);
      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorModel = ErrorModel.fromJson(e.response?.data);
      throw ServerException(errorModel);
    } catch (e) {
      throw ServerException(ErrorModel(
          errorMessage: 'An unexpected error occurred during token refresh',
          status: 500));
    }
  }
}