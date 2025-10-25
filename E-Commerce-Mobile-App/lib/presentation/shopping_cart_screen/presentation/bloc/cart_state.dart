// lib/presentation/shopping_cart_screen/bloc/cart_state.dart
part of 'cart_bloc.dart';

@immutable
abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final String? recentlyRemovedItem;
  final String? promoCode;

  CartLoaded({required this.items, this.recentlyRemovedItem, this.promoCode});
}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}