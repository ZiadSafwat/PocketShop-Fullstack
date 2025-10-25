import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../core/errors/expentions.dart';
import '../models/login_response_model.dart';
import '../../../../core/databases/cache/cache_helper.dart';

class AuthLocalDataSource {
  final CacheHelper cache;
  final String tokenKey = "CACHED_TOKEN";
  final String userKey = "CACHED_USER";

  AuthLocalDataSource({required this.cache});

  Future<void> cacheToken(String token) async {
    await cache.saveData(key: tokenKey, value: token);
  }

  Future<void> cacheUser(LoginResponseModel user) async {
    await cache.saveData(
      key: userKey,
      value: json.encode(user.toJson()),
    );
  }
  Future<bool> logout() async {
    try {
      await cache.removeData(key: userKey);
      return   await cache.removeData(key: tokenKey);

     } catch (e) {

      return false;
    }
  }
  Future<String?> getToken() async {
    final token = cache.getDataString(key: tokenKey);
    return token;

  }

  Future<LoginResponseModel> getUser() async {
    final jsonString = cache.getDataString(key: userKey);
    if (jsonString != null) {
      return LoginResponseModel.fromJson(json.decode(jsonString));
    }
    throw CacheException(errorMessage: "No user data found");
  }

  // New method: Check if token is valid
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      return !JwtDecoder.isExpired(token!);
    } catch (e) {
      print(e);
      return false;
    }
  }

  // New method: Get token expiration time
  // Future<DateTime> getTokenExpiration() async {
  //   final token = await getToken();
  //   return JwtDecoder.getExpirationDate(token);
  // }

  // New method: Check if token will expire soon (within 5 hours)
  Future<bool> isTokenAboutToExpire() async {
    try {
      final token = await getToken();
      final expiration = JwtDecoder.getExpirationDate(token!);
      final now = DateTime.now();
      return expiration.isBefore(now.add(const Duration(hours: 5)));
    } catch (e) {
      return true;
    }
  }
}