import 'package:equatable/equatable.dart';
import 'package:fluttermart/presentation/search/data/models/search_response_model.dart';
import 'package:fluttermart/presentation/search/domain/entities/search_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchEntity> products;
  final bool hasReachedMax;
  final PaginationModel pagination;

  const SearchLoaded({
    required this.products,
    required this.hasReachedMax,
    required this.pagination,
  });

  SearchLoaded copyWith({
    List<SearchEntity>? products,
    bool? hasReachedMax,
    PaginationModel? pagination,
  }) {
    return SearchLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  List<Object> get props => [products, hasReachedMax, pagination];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object> get props => [message];
}