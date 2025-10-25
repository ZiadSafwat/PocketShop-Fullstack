class SearchEntity {
  final String productId;
  final String titleEn;
  final String titleAr;
  final double price;
  final List<String> images;
  final String descriptionEn;
  final String descriptionAr;
  final int stock;
  final double discountPercentage;
  final String? categoryId;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final double rating;
  final int reviewCount;
  final bool isWishlist;
  final String userId;
  final String userWishListId;
  final List<String> sizes;
  final List<String> colorsEn;
  final List<String> colorsAr;

  SearchEntity({
    required this.productId,
    required this.titleEn,
    required this.titleAr,
    required this.price,
    required this.images,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.stock,
    required this.discountPercentage,
    required this.categoryId,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.rating,
    required this.reviewCount,
    required this.isWishlist,
    required this.userId,
    required this.userWishListId,
    required this.sizes,
    required this.colorsEn,
    required this.colorsAr,
  });
  SearchEntity copyWith({
    String? productId,
    String? titleEn,
    String? titleAr,
    double? price,
    List<String>? images,
    String? descriptionEn,
    String? descriptionAr,
    int? stock,
    double? discountPercentage,
    String? categoryId,
    String? categoryNameEn,
    String? categoryNameAr,
    double? rating,
    int? reviewCount,
    bool? isWishlist,
    String? userId,
    String? userWishListId,
    List<String>? sizes,
    List<String>? colorsEn,
    List<String>? colorsAr,
  }) {
    return SearchEntity(
      productId: productId ?? this.productId,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      price: price ?? this.price,
      images: images ?? this.images,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      stock: stock ?? this.stock,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      categoryId: categoryId ?? this.categoryId,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isWishlist: isWishlist ?? this.isWishlist,
      userId: userId ?? this.userId,
      userWishListId: userWishListId ?? this.userWishListId,
      sizes: sizes ?? this.sizes,
      colorsEn: colorsEn ?? this.colorsEn,
      colorsAr: colorsAr ?? this.colorsAr,
    );
  }
}