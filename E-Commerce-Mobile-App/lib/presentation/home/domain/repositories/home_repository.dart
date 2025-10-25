import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/home_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeEntity>> getHomeData();
  Future<Either<Failure, void>> removeRecentSearch(String search);
  Future<Either<Failure, void>> addTOFav(String favItem,bool addOrRemove,String wishListId,String type);
}