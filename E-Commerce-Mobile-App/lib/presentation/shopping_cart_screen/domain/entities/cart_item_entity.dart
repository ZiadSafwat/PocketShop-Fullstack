// lib/domain/entities/cart_item_entity.dart
class CartItemEntity {
  final int id;
  final String name;
  final String image;
  final double price;
  final double? originalPrice;
  final int quantity;
  final String? size;
  final String? color;
  final bool inStock;

  CartItemEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.originalPrice,
    required this.quantity,
    this.size,
    this.color,
    required this.inStock,
  });

  // Add toJson method
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