// lib/domain/usecases/get_cart_items.dart
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItems {
  final CartRepository repository;

  GetCartItems(this.repository);

  Future<List<CartItemEntity>> call() {
    return repository.getCartItems();
  }
}