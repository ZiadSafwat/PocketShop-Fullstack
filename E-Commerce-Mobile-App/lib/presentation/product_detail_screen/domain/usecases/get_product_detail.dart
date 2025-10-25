import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/product_detail_entity.dart';
import '../repositories/product_detail_repository.dart';

class GetProductDetail {
  final ProductDetailRepository repository;

  GetProductDetail(this.repository);

  Future<Either<Failure, ProductDetailEntity>> call(String productId) {
    return repository.getProductDetail(productId);
  }
}

class AddTOFavPro {
  final ProductDetailRepository repository;

  AddTOFavPro(this.repository);

  Future<Either<Failure, void>> call(String favItem, bool addOrRemove ,String wishListId) async {
    return await repository.addTOFav(favItem, addOrRemove, wishListId);
  }
}