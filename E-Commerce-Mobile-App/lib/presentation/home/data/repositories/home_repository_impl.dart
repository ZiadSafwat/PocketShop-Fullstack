import 'package:dartz/dartz.dart';
import 'package:fluttermart/core/connection/network_info.dart';
import 'package:fluttermart/core/errors/expentions.dart';
import '../../../../core/errors/failure.dart';
import '../../../Auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/home_response_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final AuthLocalDataSource authLocalDataSource;

  HomeRepositoryImpl({
    required this.authLocalDataSource,
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, HomeEntity>> getHomeData() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteHomeData = await remoteDataSource.getHomeData();
        localDataSource.cacheHomeData(remoteHomeData);
        return Right(remoteHomeData);
      } on ServerException catch (e) {
        // Fallback to local cache on server failure
        try {
          final localHomeData = await localDataSource.getCachedHomeData();
          return Right(localHomeData);
        } on CacheException {
          return Left(ServerFailure(
            errMessage: e.errorModel.errorMessage,
            statusCode: e.errorModel.status,
          ));
        }
      }
    } else {
      try {
        final localHomeData = await localDataSource.getCachedHomeData();
        return Right(localHomeData);
      } on CacheException {
        return Left(CacheFailure(
            errMessage: 'No internet connection and no local data available'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> removeRecentSearch(String search) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeRecentSearch(search);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(errMessage: e.errorModel.errorMessage));
      }
    } else {
      return Left(CacheFailure(
          errMessage: 'Cannot remove recent search without an internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> addTOFav(
      String favItem, bool addOrRemove, String wishListId, String type) async {
    // Optimistically update the local cache first
    try {
      final localHomeData = await localDataSource.getCachedHomeData();
      HomeResponseModel updatedHomeData = _updateHomeData(
          localHomeData, type, favItem, addOrRemove);

      await localDataSource.cacheHomeData(updatedHomeData);
    } on CacheException {
      // If there's no cache, we can't perform an optimistic update.
      // We will proceed with the remote call.
    }

    // Attempt the remote update
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addTOFav(favItem, addOrRemove, wishListId);
        return const Right(null);
      } on ServerException catch (e) {
        // If the remote update fails, revert the local cache to its previous state
        try {
          final localHomeData = await localDataSource.getCachedHomeData();
          HomeResponseModel revertedHomeData = _updateHomeData(
              localHomeData, type, favItem, !addOrRemove);
          await localDataSource.cacheHomeData(revertedHomeData);
        } on CacheException {
          // If a cache failure occurs while reverting, we just ignore it.
          // The main failure is the server error.
        }
        return Left(ServerFailure(errMessage: e.errorModel.errorMessage));
      }
    } else {
      // If there's no internet, revert the local optimistic update
      try {
        final localHomeData = await localDataSource.getCachedHomeData();
        HomeResponseModel revertedHomeData = _updateHomeData(
            localHomeData, type, favItem, !addOrRemove);
        await localDataSource.cacheHomeData(revertedHomeData);
      } on CacheException {
        // If a cache failure occurs, we just return the main failure.
      }
      return Left(CacheFailure(
          errMessage: 'Cannot add to favorites without an internet connection'));
    }
  }

  HomeResponseModel _updateHomeData(
      HomeResponseModel data, String type, String favItem, bool addOrRemove) {
    if (type == 'Trending') {
      return data.copyWith(
        trendingProducts: data.trendingProducts
            .map((p) => p.productId == favItem
            ? p.copyWith(isWishlist: addOrRemove)
            : p)
            .toList(),
      );
    } else if (type == 'Recommended') {
      return data.copyWith(
        recommendedProducts: data.recommendedProducts
            .map((p) => p.productId == favItem
            ? p.copyWith(isWishlist: addOrRemove)
            : p)
            .toList(),
      );
    } else if (type == 'Arrivals') {
      return data.copyWith(
        newArrivals: data.newArrivals
            .map((p) => p.productId == favItem
            ? p.copyWith(isWishlist: addOrRemove)
            : p)
            .toList(),
      );
    }
    return data;
  }
}