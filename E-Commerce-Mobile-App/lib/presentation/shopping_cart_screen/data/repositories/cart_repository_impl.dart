// lib/data/repositories/cart_repository_impl.dart
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required this.localDataSource});

  final CartLocalDataSource localDataSource;

  @override
  Future<List<CartItemEntity>> getCartItems() {
    return localDataSource.getCartItems();
  }

  @override
  Future<void> addToCart(CartItemEntity item) {
    return localDataSource.addToCart(item);
  }

  @override
  Future<void> removeFromCart(int itemId) {
    return localDataSource.removeFromCart(itemId);
  }

  @override
  Future<void> updateQuantity(int itemId, int newQuantity) {
    return localDataSource.updateQuantity(itemId, newQuantity);
  }

  @override
  Future<void> clearCart() {
    return localDataSource.clearCart();
  }

  @override
  Future<void> applyPromoCode(String code) {
    return localDataSource.applyPromoCode(code);
  }

  @override
  Future<String?> getAppliedPromoCode() {
    return localDataSource.getAppliedPromoCode();
  }

  @override
  double calculateTotal(List<CartItemEntity> items) {
    final subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.08;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    return subtotal + tax + shipping;
  }
}