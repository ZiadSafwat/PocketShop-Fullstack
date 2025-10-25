part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class RemoveSearchEvent extends HomeEvent {
  final String search;

  const RemoveSearchEvent(this.search);

  @override
  List<Object> get props => [search];
}
class FavEvent extends HomeEvent {
  final String itemId;
  final String type;
 final bool addOrRemove;
  final String wishListId;
  const FavEvent(this.itemId, this.addOrRemove, this.wishListId,this.type);

  @override
  List<Object> get props => [itemId,addOrRemove,wishListId,type];
}
class UpdateWishlistLocal extends HomeEvent {
  final String itemId;
  final bool addOrRemove;


  const UpdateWishlistLocal({required this.itemId, required this.addOrRemove});

  @override
  List<Object> get props => [itemId, addOrRemove];
}