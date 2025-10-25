import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/product_detail_entity.dart';

abstract class ProductDetailRepository {
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(String productId);
  Future<Either<Failure, void>> addTOFav(String favItem,bool addOrRemove,String wishListId);

}