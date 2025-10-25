import 'dart:convert';

import 'package:fluttermart/core/databases/cache/cache_helper.dart';

import '../../../../core/errors/expentions.dart';
import '../models/search_response_model.dart';

abstract class SearchLocalDataSource {
  Future<void> cacheSearchResults(SearchResponseModel results);
  Future<SearchResponseModel> getCachedSearchResults();
}
 class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final CacheHelper cacheHelper;

  SearchLocalDataSourceImpl({required this.cacheHelper});

  @override
  Future<void> cacheSearchResults(SearchResponseModel results) async {
    await cacheHelper.saveData(
      key: 'cached_search_results',
      value: jsonEncode(results.toJson()),  // Change from toString() to toJson()
    );
  }

  @override
  Future<SearchResponseModel> getCachedSearchResults() async {
    final cachedData = cacheHelper.getData(key: 'cached_search_results');
    if (cachedData != null) {
      return SearchResponseModel.fromJson(cachedData);
    }
    throw CacheException(errorMessage: 'No cached search results');
  }
}
