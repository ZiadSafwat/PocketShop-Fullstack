// lib/domain/usecases/apply_promo_code.dart
import '../repositories/cart_repository.dart';

class ApplyPromoCode {
  final CartRepository repository;

  ApplyPromoCode(this.repository);

  Future<void> call(String code) {
    return repository.applyPromoCode(code);
  }
}
