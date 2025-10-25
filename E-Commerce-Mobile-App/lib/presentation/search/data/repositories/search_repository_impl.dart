import 'package:dartz/dartz.dart';
import 'package:fluttermart/core/connection/network_info.dart';
import 'package:fluttermart/core/errors/expentions.dart';
import 'package:fluttermart/presentation/search/data/datasources/search_local_data_source.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';
import '../models/search_response_model.dart'; // Import the response model

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SearchResponseModel>> searchProducts({
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
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.searchProducts(
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

        // Cache the results
        await localDataSource.cacheSearchResults(result);

        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(errMessage: e.errorModel.errorMessage));
      }
    } else {
      try {
        // Try to get cached results when offline
        final cachedResults = await localDataSource.getCachedSearchResults();
        return Right(cachedResults);
      } on CacheException {
        return Left(ConnectionFailure(
            errMessage: 'No internet connection and no cached data'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateFavState(
      {required String itemId, required String userWishListId,required bool isFav, })
  async{

    if (await networkInfo.isConnected) {
      try {

       final result = await remoteDataSource.updateFavState(
       itemId:  itemId,
       userWishListId:  userWishListId,
       isFav:  isFav,
         );
         return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(errMessage: e.errorModel.errorMessage));
      }
    } else {
      return Left(ConnectionFailure(
          errMessage: 'No internet connection and no cached data'));
    }
  }





}


