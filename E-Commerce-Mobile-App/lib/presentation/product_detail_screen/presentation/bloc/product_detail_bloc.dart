import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/usecases/get_product_detail.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetail getProductDetail;
  final AddTOFavPro addTOFav;


  ProductDetailBloc({required this.addTOFav,required this.getProductDetail}) : super(ProductDetailInitial()) {
    on<FetchProductDetail>((event, emit) async {
      emit(ProductDetailLoading());
      final result = await getProductDetail(event.productId);

      result.fold(
            (failure) => emit(ProductDetailError(message: failure.errMessage)),
            (productDetail) {emit(ProductDetailLoaded(productDetail: productDetail));
            print(productDetail.price);
            }
      );
    });
    on<FavEvent>(_addTOFav);
   }


  Future<void> _addTOFav(
      FavEvent event,
      Emitter<ProductDetailState> emit,
      ) async {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      // Save the current state for potential rollback
      final previousState = currentState.productDetail;


      // Perform optimistic update
      ProductDetailEntity updatedHome = currentState.productDetail.copyWith(isWishlist: event.addOrRemove );

      // Emit the optimistic update
      emit(ProductDetailLoaded( productDetail: updatedHome));

      // Execute the API call
      final result = await addTOFav(
        event.itemId,
        event.addOrRemove,
        event.wishListId

      );

      result.fold(
            (failure) {
          emit(ProductDetailLoaded(productDetail: previousState));

        },
            (_) {
          // Success: state is already updated
              event.updatePrevPageState();
        },
      );
    }
  }

}