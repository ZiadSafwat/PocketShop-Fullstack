// lib/domain/usecases/remove_from_cart.dart
import '../repositories/cart_repository.dart';

class RemoveFromCart {
  final CartRepository repository;

  RemoveFromCart(this.repository);

  Future<void> call(int itemId) {
    return repository.removeFromCart(itemId);
  }
}