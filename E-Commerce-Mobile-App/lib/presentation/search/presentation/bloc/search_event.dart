import 'dart:ffi';
import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchProductsEvent extends SearchEvent {
  final String query;
  final String? category;
  final List<String>? colors; // Add this
  final List<String>? sizes; // Add this
  final double? minPrice;
  final double? maxPrice;
  final double? minRating; // Add this
  final String orderBy;
  final String orderDirection;
  final int limit;
  final int offset;

  const SearchProductsEvent({
    required this.query,
    this.category,
    this.colors, // Add this
    this.sizes, // Add this
    this.minPrice,
    this.maxPrice,
    this.minRating, // Add this
    this.orderBy = 'title_en',
    this.orderDirection = 'ASC',
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object> get props => [
        query,
        orderBy,
        orderDirection,
        limit,
        offset,
      ];
}

class LoadMoreProductsEvent extends SearchEvent {
  const LoadMoreProductsEvent();
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class SearchUpdateFavEvent extends SearchEvent {
  final String itemId;
  final String userWishListId;
  final bool isFav;
  final bool isFake;
  final VoidCallback updatePrevPageState;
  const SearchUpdateFavEvent(
      this.itemId, this.userWishListId, this.isFav, this.isFake, this.updatePrevPageState);

  @override
  List<Object> get props => [itemId, userWishListId, isFav, isFake];
}
