import 'package:dartz/dartz.dart';
import '../../../../core/connection/network_info.dart';
import '../../../../core/errors/expentions.dart';
import '../../../../core/errors/failure.dart';
import '../datasources/product_detail_remote_data_source.dart';
import '../models/product_detail_response_model.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/repositories/product_detail_repository.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource remoteDataSource;
  // final ProductDetailLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductDetailRepositoryImpl({
    required this.remoteDataSource,
    // required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(
      String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProductDetail =
            await remoteDataSource.getProductDetail(productId);

        // Cache the data
        // localDataSource.cacheProductDetail(remoteProductDetail);
        print(remoteProductDetail.price);
        return Right(remoteProductDetail.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(errMessage: e.errorModel.errorMessage));
      }
    } else {
      return Left(ServerFailure(errMessage: "No internet connection"));

      // try {
      //   final localProductDetail = await localDataSource.getLastProductDetail();
      //   return Right(localProductDetail.toEntity());
      // } on CacheException {
      //   return Left(CacheFailure(message: 'No internet connection and no cached data'));
      // }
    }
  }

  @override
  Future<Either<Failure, void>> addTOFav(
    String favItem,
    bool addOrRemove,
    String wishListId,
  ) async {
    try {
      // Update on remote
      await remoteDataSource.addTOFav(favItem, addOrRemove, wishListId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(errMessage: e.errorModel.errorMessage));
    }
  }
}
