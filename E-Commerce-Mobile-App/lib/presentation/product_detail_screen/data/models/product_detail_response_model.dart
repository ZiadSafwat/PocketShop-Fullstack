import 'package:fluttermart/presentation/product_detail_screen/domain/entities/product_detail_entity.dart';


class ProductDetailResponseModel {
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
  final List<ProductReviewModel> reviews;
  final List<RelatedProductModel> relatedProducts;

  ProductDetailResponseModel({
    required this.colorEn, required this.colorAr, required this.size,
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
  factory ProductDetailResponseModel.fromJson(Map<String, dynamic> res) {
    final json = res['data'] as Map<String, dynamic>? ?? {};
    final productJson = json['product'] as Map<String, dynamic>? ?? {}; // Access product object

    return ProductDetailResponseModel(
      productId: productJson['productId'] ?? '',
      titleAr: productJson['title_ar'] ?? '',
      titleEn: productJson['title_en'] ?? '',
      price: (productJson['price'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(productJson['image'] ?? []), // Use 'image' from JSON
      colorAr: List<String>.from(productJson['color_ar'] ?? []),
      colorEn: List<String>.from(productJson['color_en'] ?? []),
      size: List<String>.from(productJson['size'] ?? []),
      descriptionAr: productJson['description_ar'] ?? '',
      descriptionEn: productJson['description_en'] ?? '',
      stock: productJson['stock'] ?? 0,
      discountPercentage: (productJson['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      category: productJson['category'] ?? '', // This is a JSON string array
      categoryNameAr: productJson['category_name_ar'] ?? '',
      categoryNameEn: productJson['category_name_en'] ?? '',
      rating: (productJson['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: productJson['review_count'] ?? 0,
      isWishlist: productJson['is_wishlist'] ?? false,
      reviews: (json['top_reviews'] as List? ?? [])
          .map((x) => ProductReviewModel.fromJson(x))
          .toList(),
      relatedProducts: (json['recommended_products'] as List? ?? [])
          .map((x) => RelatedProductModel.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'title_ar': titleAr,
    'title_en': titleEn,
    'price': price,
    'images': images,
    'color_ar': colorAr,
    'color_en': colorEn,
    'size': size,
    'description_ar': descriptionAr,
    'description_en': descriptionEn,
    'stock': stock,
    'discountPercentage': discountPercentage,
    'category': category,
    'category_name_ar': categoryNameAr,
    'category_name_en': categoryNameEn,
    'rating': rating,
    'review_count': reviewCount,
    'is_wishlist': isWishlist,
    'top_reviews': reviews.map((x) => x.toJson()).toList(),
    'recommended_products': relatedProducts.map((x) => x.toJson()).toList(),
  };

  /// Convert to Entity
  ProductDetailEntity toEntity() => ProductDetailEntity(
    colorEn: colorEn,
    colorAr: colorAr,
    size: size,
    productId: productId,
    titleAr: titleAr,
    titleEn: titleEn,
    price: price,
    images: images,
    descriptionAr: descriptionAr,
    descriptionEn: descriptionEn,
    stock: stock,
    discountPercentage: discountPercentage,
    category: category,
    categoryNameAr: categoryNameAr,
    categoryNameEn: categoryNameEn,
    rating: rating,
    reviewCount: reviewCount,
    isWishlist: isWishlist,
    reviews: reviews.map((x) => x.toEntity()).toList(),
    relatedProducts: relatedProducts.map((x) => x.toEntity()).toList(),
  );
}

class ProductReviewModel {
  final String id;
  final double rating;
  final String comment;
  final String created;
  final ReviewUserModel user;

  ProductReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.created,
    required this.user,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      created: json['created'] ?? '',
      user: ReviewUserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rating': rating,
    'comment': comment,
    'created': created,
    'user': user.toJson(),
  };

  ProductReviewEntity toEntity() => ProductReviewEntity(
    id: id,
    rating: rating,
    comment: comment,
    created: created,
    user: user.toEntity(),
  );
}

class ReviewUserModel {
  final String id;
  final String name;
  final List<String> avatar;

  ReviewUserModel({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: List<String>.from(json['avatar'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
  };

  ReviewUserEntity toEntity() =>
      ReviewUserEntity(id: id, name: name, avatar: avatar);
}

class RelatedProductModel {
  final String productId;
  final String titleAr;
  final String titleEn;
  final double price;
  final List<String> image;
  final double rating;
  final String currency;

  RelatedProductModel({
    required this.productId,
    required this.titleAr,
    required this.titleEn,
    required this.price,
    required this.image,
    required this.rating,
    required this.currency,
  });
  factory RelatedProductModel.fromJson(Map<String, dynamic> json) {
    return RelatedProductModel(
      productId: json['productId'] ?? '',
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: List<String>.from(json['image'] ?? []), // Use 'image' from JSON
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      currency: '\$', // Default value since JSON doesn't provide this
    );
  }


  Map<String, dynamic> toJson() => {
    'productId': productId,
    'title_ar': titleAr,
    'title_en': titleEn,
    'price': price,
    'image': image,
    'rating': rating,
    'currency': currency,
  };

  RelatedProductEntity toEntity() => RelatedProductEntity(
    productId: productId,
    titleAr: titleAr,
    titleEn: titleEn,
    price: price,
    images: image,
    rating: rating,
    currency: currency,
  );
}
