// lib/domain/repositories/cart_repository.dart
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addToCart(CartItemEntity item);
  Future<void> removeFromCart(int itemId);
  Future<void> updateQuantity(int itemId, int newQuantity);
  Future<void> clearCart();
  Future<void> applyPromoCode(String code);
  Future<String?> getAppliedPromoCode();
  double calculateTotal(List<CartItemEntity> items);
}