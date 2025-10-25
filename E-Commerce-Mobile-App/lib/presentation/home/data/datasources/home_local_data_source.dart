import 'dart:convert';

import 'package:fluttermart/core/databases/cache/cache_helper.dart';
import 'package:fluttermart/core/errors/expentions.dart';

import '../models/home_response_model.dart';

abstract class HomeLocalDataSource {
  Future<HomeResponseModel> getCachedHomeData();
  Future<void> cacheHomeData(HomeResponseModel homeData);
  Future<void> cacheRecentSearches(List<String> searches);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final CacheHelper cacheHelper;
  final String homeCacheKey = 'CACHED_HOME_DATA';
  final String recentSearchesKey = 'CACHED_RECENT_SEARCHES';

  HomeLocalDataSourceImpl({required this.cacheHelper});

  @override
  Future<HomeResponseModel> getCachedHomeData() async {
    final jsonString = cacheHelper.getDataString(key: homeCacheKey);
    if (jsonString != null) {
      return HomeResponseModel.fromJson(json.decode(jsonString));
    }
    throw CacheException(errorMessage: "No home data found");
  }

  @override
  Future<void> cacheHomeData(HomeResponseModel homeData) async {
    await cacheHelper.saveData(
      key: homeCacheKey,
      value: json.encode(homeData.toJson()),
    );
  }

  @override
  Future<void> cacheRecentSearches(List<String> searches) async {
    await cacheHelper.saveData(
      key: recentSearchesKey,
      value: json.encode(searches),
    );
  }
}