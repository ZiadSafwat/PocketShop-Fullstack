import 'package:dartz/dartz.dart';
import 'package:fluttermart/core/errors/failure.dart';
import 'package:fluttermart/presentation/search/data/models/search_response_model.dart';


abstract class SearchRepository {
  Future<Either<Failure, SearchResponseModel>> searchProducts({
    required String query,
    String? category,
    List<String>? colors,
    List<String>? sizes,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String orderBy,
    String orderDirection,
    int limit,
    int offset,
  });
  Future<Either<Failure, void>> updateFavState({
    required   String itemId,
    required  String userWishListId,
    required  bool isFav,

  });
}