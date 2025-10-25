import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/get_home_data.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeData getHomeData;
  final RemoveRecentSearch removeRecentSearch;
  final AddTOFav addTOFav;

  HomeBloc({
    required this.addTOFav,
    required this.getHomeData,
    required this.removeRecentSearch,
  }) : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<RemoveSearchEvent>(_onRemoveRecentSearch);
    on<FavEvent>(_addTOFav);
    on<UpdateWishlistLocal>(_onUpdateWishlistLocal);
  }

  Future<void> _addTOFav(
      FavEvent event,
      Emitter<HomeState> emit,
      ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // Save the current state for potential rollback
      final previousState = currentState.homeData;

      // Perform optimistic update
      HomeEntity updatedHome;
      switch (event.type) {
        case 'Trending':
          updatedHome = currentState.homeData.copyWith(
            trendingProducts: _updateWishlistStatus(
              currentState.homeData.trendingProducts,
              event.itemId,
              event.addOrRemove,
            ),
          );
          break;
        case 'Recommended':
          updatedHome = currentState.homeData.copyWith(
            recommendedProducts: _updateWishlistStatus(
              currentState.homeData.recommendedProducts,
              event.itemId,
              event.addOrRemove,
            ),
          );
          break;
        case 'Arrivals':
          updatedHome = currentState.homeData.copyWith(
            newArrivals: _updateWishlistStatus(
              currentState.homeData.newArrivals,
              event.itemId,
              event.addOrRemove,
            ),
          );
          break;
        default:
          updatedHome = currentState.homeData;
      }

      // Emit the optimistic update
      emit(HomeLoaded(updatedHome));

      // Execute the API call
      final result = await addTOFav(
        event.itemId,
        event.addOrRemove,
        event.wishListId,
        event.type,
      );

      result.fold(
            (failure) {
          emit(HomeLoaded(previousState));
        },
            (_) {
          // Success: state is already updated
        },
      );
    }
  }

  // Add this new event handler
  void _onUpdateWishlistLocal(
      UpdateWishlistLocal event,
      Emitter<HomeState> emit,
      ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      // Update all product lists with the new wishlist status
      final updatedTrending = _updateWishlistStatus(
        currentState.homeData.trendingProducts,
        event.itemId,
        event.addOrRemove,
      );

      final updatedRecommended = _updateWishlistStatus(
        currentState.homeData.recommendedProducts,
        event.itemId,
        event.addOrRemove,
      );

      final updatedNewArrivals = _updateWishlistStatus(
        currentState.homeData.newArrivals,
        event.itemId,
        event.addOrRemove,
      );

      // Create updated home data
      final updatedHomeData = currentState.homeData.copyWith(
        trendingProducts: updatedTrending,
        recommendedProducts: updatedRecommended,
        newArrivals: updatedNewArrivals,
      );

      // Emit the updated state
      emit(HomeLoaded(updatedHomeData));
    }
  }

  // Helper method to update wishlist status in a product list
  List<ProductEntity> _updateWishlistStatus(
      List<ProductEntity> products,
      String itemId,
      bool addOrRemove,
      ) {
    return products.map((p) => p.productId == itemId
        ? p.copyWith(isWishlist: addOrRemove)
        : p).toList();
  }

  Future<void> _onFetchHomeData(
      FetchHomeData event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());
    final result = await getHomeData();
    result.fold(
          (failure) => emit(HomeError(_mapFailureToMessage(failure))),
          (homeData) => emit(HomeLoaded(homeData)),
    );
  }

  Future<void> _onRefreshHomeData(
      RefreshHomeData event,
      Emitter<HomeState> emit,
      ) async {
    final result = await getHomeData();
    result.fold(
          (failure) => emit(HomeError(_mapFailureToMessage(failure))),
          (homeData) => emit(HomeLoaded(homeData)),
    );
  }

  Future<void> _onRemoveRecentSearch(
      RemoveSearchEvent event,
      Emitter<HomeState> emit,
      ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final result = await removeRecentSearch(event.search);

      result.fold(
            (failure) {},
            (_) {
          final updatedSearches =
          List<String>.from(currentState.homeData.recentSearches)
            ..remove(event.search);

          emit(HomeLoaded(currentState.homeData.copyWith(
            recentSearches: updatedSearches,
          )));
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.errMessage;
    } else if (failure is CacheFailure) {
      return failure.errMessage;
    } else {
      return 'Unexpected error';
    }
  }
}