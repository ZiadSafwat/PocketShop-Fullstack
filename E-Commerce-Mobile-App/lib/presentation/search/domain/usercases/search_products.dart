import 'package:dartz/dartz.dart';
import 'package:fluttermart/core/errors/failure.dart';
import 'package:fluttermart/presentation/search/data/models/search_response_model.dart';
import 'package:fluttermart/presentation/search/domain/repositories/search_repository.dart';

class SearchProducts {
  final SearchRepository repository;

  SearchProducts(this.repository);

  Future<Either<Failure, SearchResponseModel>> call({
    required String query,
    String? category,
    List<String>? colors,
    List<String>? sizes,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String orderBy = 'title_en',
    String orderDirection = 'ASC',
    int limit = 4,
    int offset = 0,
  }) async {
    return await repository.searchProducts(
      query: query,
      category: category,
      colors: colors,
      sizes: sizes,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      orderBy: orderBy,
      orderDirection: orderDirection,
      limit: limit,
      offset: offset,
    );
  }
}

class UpdateFavState {
  final SearchRepository repository;

  UpdateFavState(this.repository);

  Future<Either<Failure, void>> call({
    required String itemId,
    required String userWishListId,
    required bool isFav,
  }) async {
    return await repository.updateFavState(
      itemId: itemId,
      userWishListId: userWishListId,
      isFav: isFav,
    );
  }
}
