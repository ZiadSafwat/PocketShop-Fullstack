import 'dart:convert';

import 'package:fluttermart/core/databases/cache/cache_helper.dart';

import '../models/cart_item_model.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(CartItemEntity item);
  Future<void> removeFromCart(int itemId);
  Future<void> updateQuantity(int itemId, int newQuantity);
  Future<void> clearCart();
  Future<void> applyPromoCode(String code);
  Future<String?> getAppliedPromoCode();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl({required this.cacheHelper});

  final CacheHelper cacheHelper;

  static const String _cartItemsKey = 'local_cart_items';
  static const String _promoCodeKey = 'local_cart_promo_code';

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final raw = cacheHelper.getDataString(key: _cartItemsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((dynamic item) => CartItemModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addToCart(CartItemEntity item) async {
    final items = await getCartItems();
    final incoming = CartItemModel.fromEntity(item);
    final existingIndex = items.indexWhere((element) => element.id == incoming.id);

    if (existingIndex >= 0) {
      final existing = items[existingIndex];
      items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + incoming.quantity,
        price: incoming.price,
        originalPrice: incoming.originalPrice,
        inStock: incoming.inStock,
        size: incoming.size,
        color: incoming.color,
        name: incoming.name,
        image: incoming.image,
      );
    } else {
      items.add(incoming);
    }

    await _persist(items);
  }

  @override
  Future<void> removeFromCart(int itemId) async {
    final items = await getCartItems();
    items.removeWhere((element) => element.id == itemId);
    await _persist(items);
  }

  @override
  Future<void> updateQuantity(int itemId, int newQuantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((element) => element.id == itemId);
    if (index == -1) {
      return;
    }

    if (newQuantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: newQuantity);
    }

    await _persist(items);
  }

  @override
  Future<void> clearCart() async {
    await cacheHelper.removeData(key: _cartItemsKey);
    await cacheHelper.removeData(key: _promoCodeKey);
  }

  @override
  Future<void> applyPromoCode(String code) async {
    await cacheHelper.saveData(key: _promoCodeKey, value: code);
  }

  @override
  Future<String?> getAppliedPromoCode() async {
    return cacheHelper.getDataString(key: _promoCodeKey);
  }

  Future<void> _persist(List<CartItemModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await cacheHelper.saveData(key: _cartItemsKey, value: encoded);
  }
}
