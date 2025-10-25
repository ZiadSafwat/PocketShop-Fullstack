// lib/presentation/shopping_cart_screen/bloc/cart_event.dart
part of 'cart_bloc.dart';

@immutable
abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class RemoveItemEvent extends CartEvent {
  final int itemId;
  final String itemName;

  RemoveItemEvent({required this.itemId, required this.itemName});
}

class UpdateQuantityEvent extends CartEvent {
  final int itemId;
  final int newQuantity;

  UpdateQuantityEvent({required this.itemId, required this.newQuantity});
}

class ClearCartEvent extends CartEvent {}

class ApplyPromoCodeEvent extends CartEvent {
  final String code;

  ApplyPromoCodeEvent({required this.code});
}