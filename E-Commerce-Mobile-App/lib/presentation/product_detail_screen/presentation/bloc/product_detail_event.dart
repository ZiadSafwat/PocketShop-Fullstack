part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchProductDetail extends ProductDetailEvent {
  final String productId;

  const FetchProductDetail({required this.productId});

  @override
  List<Object> get props => [productId];
}

class FavEvent extends ProductDetailEvent {
  final String itemId;
   final bool addOrRemove;
  final String wishListId;
  final VoidCallback updatePrevPageState;
  const FavEvent(this.itemId, this.addOrRemove, this.wishListId, this.updatePrevPageState);

  @override
  List<Object> get props => [itemId,addOrRemove,wishListId];
}