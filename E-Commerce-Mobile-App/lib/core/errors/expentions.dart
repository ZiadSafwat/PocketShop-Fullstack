import 'dart:io';

import 'package:dio/dio.dart';
import 'error_model.dart';

//!ServerException
class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException(this.errorModel);
}

//!CacheExeption
class CacheException implements Exception {
  final String errorMessage;
  CacheException({required this.errorMessage});
}

class BadCertificateException extends ServerException {
  BadCertificateException(super.errorModel);
}

class ConnectionTimeoutException extends ServerException {
  ConnectionTimeoutException(super.errorModel);
}

class BadResponseException extends ServerException {
  BadResponseException(super.errorModel);
}

class ReceiveTimeoutException extends ServerException {
  ReceiveTimeoutException(super.errorModel);
}

class ConnectionErrorException extends ServerException {
  ConnectionErrorException(super.errorModel);
}

class SendTimeoutException extends ServerException {
  SendTimeoutException(super.errorModel);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException(super.errorModel);
}

class ForbiddenException extends ServerException {
  ForbiddenException(super.errorModel);
}

class NotFoundException extends ServerException {
  NotFoundException(super.errorModel);
}

class CofficientException extends ServerException {
  CofficientException(super.errorModel);
}

class CancelException extends ServerException {
  CancelException(super.errorModel);
}

class UnknownException extends ServerException {
  UnknownException(super.errorModel);
}

// Helper function to extract error information from DioException
ErrorModel _getErrorModelFromDioException(DioException e) {
  // Handle cases where response might be null or not JSON
  if (e.response == null) {
    return ErrorModel(
      status: 0,
      errorMessage: e.message ?? 'No response from server',
    );
  }

  // Handle HTML responses (like 500 errors)
  if (e.response!.data is String) {
    final htmlResponse = e.response!.data as String;
    // Extract meaningful information from HTML if possible
    if (htmlResponse.contains('Could not launch container')) {
      return ErrorModel(
        status: e.response?.statusCode ?? 500,
        errorMessage: 'Server container issue. Please try again later.',
      );
    }
    return ErrorModel(
      status: e.response?.statusCode ?? 500,
      errorMessage: 'Server error: ${e.response?.statusCode}',
    );
  }

  // Handle JSON responses
  if (e.response!.data is Map<String, dynamic>) {
    return ErrorModel.fromJson(e.response!.data);
  }

  // Fallback for other response types
  return ErrorModel(
    status: e.response?.statusCode ?? 0,
    errorMessage: e.response?.data?.toString() ?? e.message ?? 'Unknown error',
  );
}

handleDioException(DioException e) {
  final errorModel = _getErrorModelFromDioException(e);

  switch (e.type) {
    case DioExceptionType.connectionError:
      throw ConnectionErrorException(errorModel);
    case DioExceptionType.badCertificate:
      throw BadCertificateException(errorModel);
    case DioExceptionType.connectionTimeout:
      throw ConnectionTimeoutException(errorModel);
    case DioExceptionType.receiveTimeout:
      throw ReceiveTimeoutException(errorModel);
    case DioExceptionType.sendTimeout:
      throw SendTimeoutException(errorModel);
    case DioExceptionType.badResponse:
      switch (e.response?.statusCode) {
        case 400: // Bad request
          throw BadResponseException(errorModel);
        case 401: //unauthorized
          throw UnauthorizedException(errorModel);
        case 403: //forbidden
          throw ForbiddenException(errorModel);
        case 404: //not found
          throw NotFoundException(errorModel);
        case 409: //cofficient
          throw CofficientException(errorModel);
        case 500: // Internal server error
          throw ServerException(errorModel);
        case 504: // Gateway timeout
          throw BadResponseException(
              ErrorModel(status: 504, errorMessage: 'Gateway timeout'));
      }
      // For any other status code not explicitly handled
      throw ServerException(errorModel);
    case DioExceptionType.cancel:
      throw CancelException(
          ErrorModel(errorMessage: 'Request cancelled', status: -1));
    case DioExceptionType.unknown:
      if (e.error is SocketException || e.error is HttpException) {
        throw ConnectionErrorException(
            ErrorModel(errorMessage: 'Network connection failed', status: 0));
      }
      throw UnknownException(
          ErrorModel(errorMessage: e.toString(), status: 500));
  }
}