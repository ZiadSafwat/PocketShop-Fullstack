import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/errors/error_model.dart';
import '../../../../core/errors/expentions.dart';
import '../models/search_response_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResponseModel> searchProducts({
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
  Future<void> updateFavState({
    required  String itemId,
    required   String userWishListId,
    required   bool isFav,

  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiConsumer apiConsumer;

  SearchRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<SearchResponseModel> searchProducts({
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
    final Map<String, dynamic> queryParams = {
      'q': query,
      if (category != null && category.isNotEmpty) 'category': category,
      if (colors != null && colors.isNotEmpty) 'colors': colors.join(','),
      if (sizes != null && sizes.isNotEmpty) 'sizes': sizes.join(','),
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minRating != null && minRating != 0)
        'minRating': minRating, // Fixed condition
      'orderBy': orderBy,
      'orderDirection': orderDirection,
      'limit': limit,
      'offset': offset,
    };

    final response = await apiConsumer.get(
      'new/search',
      queryParameters: queryParams,
    );

    return SearchResponseModel.fromJson(response);
  }

  @override
  Future<void> updateFavState(
      {required String itemId, required String userWishListId,required bool isFav, }) async {

    final appendOrRemove = isFav ? "products+" : "products-";

    final body = {
      appendOrRemove: [itemId],
    };
    try {
      final response = await apiConsumer.patch("${EndPoints.wish_list_items}$userWishListId",data: body,isFormData: true );
      if (response == null) {
        throw   ServerException(ErrorModel(
          status: 500,
          errorMessage: 'Null response from server',
        ));
      }
    }on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(ErrorModel(
        status: 500,
        errorMessage: 'Failed to parse response: $e',
      ));
    }
  }
}
