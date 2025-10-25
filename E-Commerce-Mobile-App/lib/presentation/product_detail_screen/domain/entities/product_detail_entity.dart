import 'package:equatable/equatable.dart';

class ProductDetailEntity extends Equatable {
  final String productId;
  final String titleAr;
  final String titleEn;
  final double price;
  final List<String> images;
  final List<String> colorEn;
  final List<String> colorAr;
  final List<String> size;
  final String descriptionAr;
  final String descriptionEn;
  final int stock;
  final double discountPercentage;
  final String category;
  final String categoryNameAr;
  final String categoryNameEn;
  final double rating;
  final int reviewCount;
  final bool isWishlist;
  final List<ProductReviewEntity> reviews;
  final List<RelatedProductEntity> relatedProducts;

  const ProductDetailEntity({
    required this.colorEn,
    required this.colorAr,
    required this.size,
    required this.productId,
    required this.titleAr,
    required this.titleEn,
    required this.price,
    required this.images,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.stock,
    required this.discountPercentage,
    required this.category,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.rating,
    required this.reviewCount,
    required this.isWishlist,
    required this.reviews,
    required this.relatedProducts,
  });

  @override
  List<Object?> get props => [
    productId,
    titleAr,
    titleEn,
    price,
    images,
    colorEn,
    colorAr,
    size,
    descriptionAr,
    descriptionEn,
    stock,
    discountPercentage,
    category,
    categoryNameAr,
    categoryNameEn,
    rating,
    reviewCount,
    isWishlist,
    reviews,
    relatedProducts,
  ];

  ProductDetailEntity copyWith({
    String? productId,
    String? titleAr,
    String? titleEn,
    double? price,
    List<String>? images,
    List<String>? colorEn,
    List<String>? colorAr,
    List<String>? size,
    String? descriptionAr,
    String? descriptionEn,
    int? stock,
    double? discountPercentage,
    String? category,
    String? categoryNameAr,
    String? categoryNameEn,
    double? rating,
    int? reviewCount,
    bool? isWishlist,
    List<ProductReviewEntity>? reviews,
    List<RelatedProductEntity>? relatedProducts,
  }) {
    return ProductDetailEntity(
      productId: productId ?? this.productId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      price: price ?? this.price,
      images: images ?? this.images,
      colorEn: colorEn ?? this.colorEn,
      colorAr: colorAr ?? this.colorAr,
      size: size ?? this.size,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      stock: stock ?? this.stock,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      category: category ?? this.category,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isWishlist: isWishlist ?? this.isWishlist,
      reviews: reviews ?? this.reviews,
      relatedProducts: relatedProducts ?? this.relatedProducts,
    );
  }
}

// Ensure Equatable and copyWith are also added to sub-classes for consistency.
class ProductReviewEntity extends Equatable {
  final String id;
  final double rating;
  final String comment;
  final String created;
  final ReviewUserEntity user;

  const ProductReviewEntity({
    required this.id,
    required this.rating,
    required this.comment,
    required this.created,
    required this.user,
  });

  @override
  List<Object?> get props => [id, rating, comment, created, user];

  ProductReviewEntity copyWith({
    String? id,
    double? rating,
    String? comment,
    String? created,
    ReviewUserEntity? user,
  }) {
    return ProductReviewEntity(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      created: created ?? this.created,
      user: user ?? this.user,
    );
  }
}

class ReviewUserEntity extends Equatable {
  final String id;
  final String name;
  final List<String> avatar;

  const ReviewUserEntity({
    required this.id,
    required this.name,
    required this.avatar,
  });

  @override
  List<Object?> get props => [id, name, avatar];

  ReviewUserEntity copyWith({
    String? id,
    String? name,
    List<String>? avatar,
  }) {
    return ReviewUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }
}

class RelatedProductEntity extends Equatable {
  final String productId;
  final String titleAr;
  final String titleEn;
  final double price;
  final List<String> images; // Corrected field name for consistency
  final double rating;
  final String currency;

  const RelatedProductEntity({
    required this.productId,
    required this.titleAr,
    required this.titleEn,
    required this.price,
    required this.images, // Corrected field name
    required this.rating,
    required this.currency,
  });

  @override
  List<Object?> get props => [
    productId,
    titleAr,
    titleEn,
    price,
    images,
    rating,
    currency,
  ];

  RelatedProductEntity copyWith({
    String? productId,
    String? titleAr,
    String? titleEn,
    double? price,
    List<String>? images,
    double? rating,
    String? currency,
  }) {
    return RelatedProductEntity(
      productId: productId ?? this.productId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      price: price ?? this.price,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      currency: currency ?? this.currency,
    );
  }
}