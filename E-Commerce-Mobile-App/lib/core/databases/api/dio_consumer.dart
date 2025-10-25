import 'package:dio/dio.dart';
import '../../../presentation/Auth/data/datasources/auth_local_data_source.dart';
import '../../errors/expentions.dart';
import 'api_consumer.dart';
import 'end_points.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  DioConsumer({
    required this.dio,
    required this.authLocalDataSource,
  }) {
    dio.options.baseUrl = EndPoints.baserUrl;

    // Add interceptors
    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
      ),
      TokenRefreshInterceptor(
        dio: dio,
        authLocalDataSource: authLocalDataSource,
      ),
    ]);
  }

  // Helper method to build headers
  Map<String, dynamic> _buildHeaders({bool isFormData = false}) {
    final headers = <String, dynamic>{};

    if (!isFormData) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  // POST
  @override
  Future post(
      String path, {
        Map<dynamic, dynamic> data = const {},
        Map<String, dynamic>? queryParameters,
        bool isFormData = false,
      }) async {
    try {
      final headers = _buildHeaders(isFormData: isFormData);

      final response = await dio.post(
        path,
        data: isFormData ? _handleFormData(data) : data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // GET
  @override
  Future<dynamic> get(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final headers = _buildHeaders();

      final response = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // DELETE
  @override
  Future<dynamic> delete(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final headers = _buildHeaders();

      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // PATCH
  @override
  Future<dynamic> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool isFormData = false,
      }) async {
    try {
      final headers = _buildHeaders(isFormData: isFormData);

      final response = await dio.patch(
        path,
        data: isFormData ? _handleFormData(data) : data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  // Handle form data conversion
  dynamic _handleFormData(dynamic data) {
    if (data == null) return FormData();
    if (data is Map<String, dynamic>) return FormData.fromMap(data);
    return data; // For custom FormData scenarios
  }
}

////////////////////////////// Refresh Token Interceptor ///////////////////////////////////
class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final AuthLocalDataSource authLocalDataSource;
  bool _isRefreshing = false;
  final List<RequestOptions> _requestsPending = [];

  TokenRefreshInterceptor({
    required Dio dio,
    required this.authLocalDataSource,
  }) : _dio = dio;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Add authorization header to all requests except refresh endpoint
    if (!options.path.contains('auth-refresh') && !options.path.contains('auth-with-password')) {
      final token = await authLocalDataSource.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRefreshToken(err)) {
      if (_isRefreshing) {
        // If already refreshing, add to pending requests
        _requestsPending.add(err.requestOptions);
        return handler.next(err);
      }

      _isRefreshing = true;

      try {
        // Get current token for refresh request
        final currentToken = await authLocalDataSource.getToken();

        if (currentToken == null) {
          throw DioException(
            requestOptions: err.requestOptions,
            error: 'No token available for refresh',
          );
        }

        // Create refresh request
        final response = await _dio.post(
          '${EndPoints.baserUrl}/api/collections/users/auth-refresh',
          options: Options(
            headers: {
              'Authorization': 'Bearer $currentToken',
              'Content-Type': 'application/json',
              'accept': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          // Extract new token from response
          final newToken = response.data['token'] ??
              response.data['access_token'] ??
              response.data['accessToken'];

          if (newToken == null) {
            throw DioException(
              requestOptions: err.requestOptions,
              error: 'No token found in refresh response',
            );
          }

          // Update the token in storage
          await authLocalDataSource.cacheToken(newToken);

          // Retry the original request with new token
          final retryResponse = await _retryRequest(err.requestOptions);

          // Retry all pending requests
          await _retryPendingRequests();

          return handler.resolve(retryResponse);
        }
      } catch (refreshError) {
        // Clear pending requests on refresh failure
        _requestsPending.clear();

        // If refresh fails, you might want to logout the user
        await authLocalDataSource.logout();

        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: 'Token refresh failed: $refreshError',
        ));
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }

  bool _shouldRefreshToken(DioException err) {
    return err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('auth-refresh') &&
        !err.requestOptions.path.contains('auth-with-password');
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await authLocalDataSource.getToken();

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: {
          ...requestOptions.headers,
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<void> _retryPendingRequests() async {
    for (var options in _requestsPending) {
      try {
        await _retryRequest(options);
      } catch (e) {
        // Handle individual request failure if needed
      }
    }
    _requestsPending.clear();
  }
}