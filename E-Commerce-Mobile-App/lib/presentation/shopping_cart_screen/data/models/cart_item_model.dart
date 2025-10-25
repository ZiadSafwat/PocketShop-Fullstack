// lib/data/models/cart_item_model.dart
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  CartItemModel({
    required super.id,
    required super.name,
    required super.image,
    required super.price,
    super.originalPrice,
    required super.quantity,
    super.size,
    super.color,
    required super.inStock,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      size: json['size'] as String?,
      color: json['color'] as String?,
      inStock: json['inStock'] as bool? ?? true,
    );
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      price: entity.price,
      originalPrice: entity.originalPrice,
      quantity: entity.quantity,
      size: entity.size,
      color: entity.color,
      inStock: entity.inStock,
    );
  }

  CartItemModel copyWith({
    int? id,
    String? name,
    String? image,
    double? price,
    double? originalPrice,
    int? quantity,
    String? size,
    String? color,
    bool? inStock,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      inStock: inStock ?? this.inStock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'size': size,
      'color': color,
      'inStock': inStock,
    };
  }
}