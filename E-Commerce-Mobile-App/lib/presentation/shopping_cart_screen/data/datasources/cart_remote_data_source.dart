// lib/data/datasources/cart_remote_data_source.dart
import 'package:fluttermart/core/databases/api/api_consumer.dart';

import '../../domain/entities/cart_item_entity.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addToCart(CartItemEntity item);
  Future<void> removeFromCart(int itemId);
  Future<void> updateQuantity(int itemId, int newQuantity);
  Future<void> clearCart();
  Future<void> applyPromoCode(String code);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiConsumer apiConsumer;
  CartRemoteDataSourceImpl({required this.apiConsumer});
  @override
  Future<void> addToCart(CartItemEntity item) {
    // TODO: implement addToCart
    throw UnimplementedError();
  }

  @override
  Future<void> applyPromoCode(String code) {
    // TODO: implement applyPromoCode
    throw UnimplementedError();
  }

  @override
  Future<void> clearCart() {
    // TODO: implement clearCart
    throw UnimplementedError();
  }

  @override
  Future<List<CartItemEntity>> getCartItems() {
    // TODO: implement getCartItems
    throw UnimplementedError();
  }

  @override
  Future<void> removeFromCart(int itemId) {
    // TODO: implement removeFromCart
    throw UnimplementedError();
  }

  @override
  Future<void> updateQuantity(int itemId, int newQuantity) {
    // TODO: implement updateQuantity
    throw UnimplementedError();
  }
}
