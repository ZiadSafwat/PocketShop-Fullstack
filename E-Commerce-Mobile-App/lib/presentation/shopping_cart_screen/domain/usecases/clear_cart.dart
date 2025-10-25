// lib/domain/usecases/clear_cart.dart
import '../repositories/cart_repository.dart';

class ClearCart {
  final CartRepository repository;

  ClearCart(this.repository);

  Future<void> call() {
    return repository.clearCart();
  }
}