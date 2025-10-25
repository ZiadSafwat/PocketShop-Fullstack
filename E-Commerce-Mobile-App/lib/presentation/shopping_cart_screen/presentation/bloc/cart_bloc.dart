// lib/presentation/shopping_cart_screen/bloc/cart_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/apply_promo_code.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/clear_cart.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/remove_from_cart.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/update_quantity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/get_cart_items.dart';
part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItems getCartItems;
  final RemoveFromCart removeFromCart;
  final UpdateQuantity updateQuantity;
  final ClearCart clearCart;
  final ApplyPromoCode applyPromoCode;

  CartBloc({
    required this.getCartItems,
    required this.removeFromCart,
    required this.updateQuantity,
    required this.clearCart,
    required this.applyPromoCode,
  }) : super(CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<RemoveItemEvent>(_onRemoveItem);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<ApplyPromoCodeEvent>(_onApplyPromoCode);
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await getCartItems();
      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError(message: 'Failed to load cart: $e'));
    }
  }

  Future<void> _onRemoveItem(RemoveItemEvent event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        await removeFromCart(event.itemId);
        final items = await getCartItems();
        emit(CartLoaded(items: items, recentlyRemovedItem: event.itemName));
      } catch (e) {
        emit(CartError(message: 'Failed to remove item: $e'));
      }
    }
  }

  Future<void> _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        await updateQuantity(event.itemId, event.newQuantity);
        final items = await getCartItems();
        emit(CartLoaded(items: items));
      } catch (e) {
        emit(CartError(message: 'Failed to update quantity: $e'));
      }
    }
  }

  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        await clearCart();
        emit(CartLoaded(items: []));
      } catch (e) {
        emit(CartError(message: 'Failed to clear cart: $e'));
      }
    }
  }

  Future<void> _onApplyPromoCode(ApplyPromoCodeEvent event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        await applyPromoCode(event.code);
        // Handle promo code application logic
        emit(CartLoaded(items: (state as CartLoaded).items, promoCode: event.code));
      } catch (e) {
        emit(CartError(message: 'Failed to apply promo code: $e'));
      }
    }
  }
}