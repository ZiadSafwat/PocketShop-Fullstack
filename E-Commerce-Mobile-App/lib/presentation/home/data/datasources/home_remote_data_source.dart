import 'package:fluttermart/core/errors/expentions.dart';
import 'package:fluttermart/core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/errors/error_model.dart';
import '../models/home_response_model.dart';
abstract class HomeRemoteDataSource {
  Future<HomeResponseModel> getHomeData( );
  Future<void> removeRecentSearch(String search);
  Future<void>  addTOFav(String favItem, bool addOrRemove,String wishListId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiConsumer apiConsumer;

  HomeRemoteDataSourceImpl({required this.apiConsumer});
// In home_remote_data_source.dart
  @override
  Future<HomeResponseModel> getHomeData() async {
    try {
      final response = await apiConsumer.get(EndPoints.homeData);
      if (response == null) {
        throw   ServerException(ErrorModel(
          status: 500,
          errorMessage: 'Null response from server',
        ));
      }
      return HomeResponseModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(ErrorModel(
        status: 500,
        errorMessage: 'Failed to parse response: $e',
      ));
    }
  }


  @override
  Future<void> removeRecentSearch(String search) async {
    try {
      final encodedQuery = Uri.encodeComponent(search);

      final response = await apiConsumer.delete(
        EndPoints.recentSearches+encodedQuery,

      );
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

  @override
  Future<void> addTOFav(String favItem, bool addOrRemove,String wishListId)async {

    final appendOrRemove = addOrRemove ? "products+" : "products-";

    final body = {
      appendOrRemove: [favItem],
    };
    try {
      final response = await apiConsumer.patch("${EndPoints.wish_list_items}$wishListId",data: body,isFormData: true );
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