import 'package:dio/dio.dart';
import 'package:fluttermart/core/errors/error_model.dart';
import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/errors/expentions.dart';
import '../models/product_detail_response_model.dart';

abstract class ProductDetailRemoteDataSource {
  Future<ProductDetailResponseModel> getProductDetail(String productId);
  Future<void>  addTOFav(String favItem, bool addOrRemove,String wishListId);

}

class ProductDetailRemoteDataSourceImpl implements ProductDetailRemoteDataSource {
   final ApiConsumer dio;

  ProductDetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProductDetailResponseModel> getProductDetail(String productId) async {
    try {
      final response = await dio.get(
        '${EndPoints.baserUrl}${EndPoints.product}$productId',
      );


        return ProductDetailResponseModel.fromJson(response  );

    } on ServerException catch (e) {
      throw ServerException(   e.errorModel   );

    }
  }




   @override
   Future<void> addTOFav(String favItem, bool addOrRemove,String wishListId)async {

     final appendOrRemove = addOrRemove ? "products+" : "products-";

     final body = {
       appendOrRemove: [favItem],
     };
     try {
       await dio.patch("${EndPoints.wish_list_items}$wishListId",data: body,isFormData: true );
     } on ServerException catch (e) {
       throw ServerException(  e.errorModel);
     }
   }
}