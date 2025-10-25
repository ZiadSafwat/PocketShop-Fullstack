import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttermart/presentation/home/presentation/bloc/home_bloc.dart';
import 'package:fluttermart/presentation/search/data/models/search_response_model.dart';
import 'package:fluttermart/presentation/search/domain/entities/search_entity.dart';
import 'package:fluttermart/presentation/search/domain/usercases/search_products.dart';
import 'package:fluttermart/presentation/search/presentation/bloc/search_event.dart';
import 'package:fluttermart/presentation/search/presentation/bloc/search_state.dart';

import '../../../home/presentation/bloc/home_bloc.dart' as home;

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchProducts searchProducts;
  final UpdateFavState updateFavState;
   final int limit = 6;
  int currentPage = 1;
  String currentQuery = '';
  String? currentCategory;
  List<String>? currentColors;
  List<String>? currentSizes;
  double? currentMinPrice;
  double? currentMaxPrice;
  double? currentMinRating;
  String currentOrderBy = 'title_en';
  String currentOrderDirection = 'ASC';
  PaginationModel? currentPagination;

  SearchBloc( { required this.updateFavState,required this.searchProducts}) : super(SearchInitial()) {
    on<SearchProductsEvent>(_onSearchProducts);
    on<LoadMoreProductsEvent>(_onLoadMoreProducts);
    on<ClearSearchEvent>(_onClearSearch);
    on<SearchUpdateFavEvent>(_onUpdateFavState);
  }

  Future<void> _onSearchProducts(
      SearchProductsEvent event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading());

    // Update current search parameters
    currentQuery = event.query;
    currentCategory = event.category;
    currentColors = event.colors;
    currentSizes = event.sizes;
    currentMinPrice = event.minPrice;
    currentMaxPrice = event.maxPrice;
    currentMinRating = event.minRating;
    currentOrderBy = event.orderBy;
    currentOrderDirection = event.orderDirection;

    final result = await searchProducts(
      query: event.query,
      category: event.category,
      colors: event.colors,
      sizes: event.sizes,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      minRating: event.minRating,
      orderBy: event.orderBy,
      orderDirection: event.orderDirection,
      limit: limit,
      offset: (event.offset - 1) * limit,
    );

    result.fold(
          (failure) => emit(SearchError(message: failure.errMessage)),
          (response) {
        currentPagination = response.pagination;
        final products = response.data.map((model) => model.toEntity()).toList();

        emit(
          SearchLoaded(
            products: products,
            hasReachedMax: currentPagination!.currentPage >= currentPagination!.totalPages,
            pagination: currentPagination!,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreProducts(
      LoadMoreProductsEvent event,
      Emitter<SearchState> emit,
      ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      if (currentState.hasReachedMax) return;

      currentPage++;

      final result = await searchProducts(
        query: currentQuery,
        category: currentCategory,
        colors: currentColors,
        sizes: currentSizes,
        minPrice: currentMinPrice,
        maxPrice: currentMaxPrice,
        minRating: currentMinRating,
        orderBy: currentOrderBy,
        orderDirection: currentOrderDirection,
        limit: limit,
        offset: (currentPage - 1) * limit,
      );

      result.fold(
            (failure) => emit(SearchError(message: failure.errMessage)),
            (response) {
          currentPagination = response.pagination;
          final newProducts = response.data.map((model) => model.toEntity()).toList();
          final allProducts = [...currentState.products, ...newProducts];

          emit(
            currentState.copyWith(
              products: allProducts,
              hasReachedMax: currentPagination!.currentPage >= currentPagination!.totalPages,
              pagination: currentPagination!,
            ),
          );
        },
      );
    }
  }

  void _onClearSearch(
      ClearSearchEvent event,
      Emitter<SearchState> emit,
      ) {
    emit(SearchInitial());
  }

  Future<void> _onUpdateFavState(
      SearchUpdateFavEvent event,
      Emitter<SearchState> emit,
      ) async {
    if (state is! SearchLoaded) return;

    final currentState = state as SearchLoaded;
    List<SearchEntity> updatedProducts = List.from(currentState.products);
    final productIndex = updatedProducts.indexWhere((p) => p.productId == event.itemId);

    if (productIndex != -1) {
      // Optimistically update the local state
      final productToUpdate = updatedProducts[productIndex];
      updatedProducts[productIndex] = productToUpdate.copyWith(
        isWishlist: event.isFav,
      );

      emit(currentState.copyWith(products: updatedProducts));

    }

    // If the event is not a fake/optimistic update, make the API request
    if (!event.isFake) {
      final result = await updateFavState(
        isFav: event.isFav,
        itemId: event.itemId,
        userWishListId: event.userWishListId,
      );

      result.fold(
            (failure) {
          // Revert the state on API failure
          List<SearchEntity> revertedProducts = List.from(currentState.products);
          final revertedIndex = revertedProducts.indexWhere((p) => p.productId == event.itemId);
          if (revertedIndex != -1) {
            revertedProducts[revertedIndex] = currentState.products[revertedIndex];
          }
          emit(SearchError(message: 'Failed to update favorite status.'));
          emit(currentState.copyWith(products: revertedProducts)); // Emit a new state with old data

        },
            (_) {
              event.updatePrevPageState();
          // On success, do nothing as the state is already updated
          // You could optionally emit a success message here
        },
      );
    }
  }
}