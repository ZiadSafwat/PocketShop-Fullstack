// lib/domain/usecases/update_quantity.dart
import '../repositories/cart_repository.dart';

class UpdateQuantity {
  final CartRepository repository;

  UpdateQuantity(this.repository);

  Future<void> call(int itemId, int newQuantity) {
    return repository.updateQuantity(itemId, newQuantity);
  }
}