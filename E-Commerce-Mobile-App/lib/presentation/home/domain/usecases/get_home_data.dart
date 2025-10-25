import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeData {
  final HomeRepository repository;

  GetHomeData(this.repository);

  Future<Either<Failure, HomeEntity>> call() async {
    return await repository.getHomeData();
  }
}

class RemoveRecentSearch {
  final HomeRepository repository;

  RemoveRecentSearch(this.repository);

  Future<Either<Failure, void>> call(String search) async {
    return await repository.removeRecentSearch(search);
  }
}

class AddTOFav {
  final HomeRepository repository;

  AddTOFav(this.repository);

  Future<Either<Failure, void>> call(String favItem, bool addOrRemove ,String wishListId,String type) async {
    return await repository.addTOFav(favItem, addOrRemove, wishListId,type);
  }
}
