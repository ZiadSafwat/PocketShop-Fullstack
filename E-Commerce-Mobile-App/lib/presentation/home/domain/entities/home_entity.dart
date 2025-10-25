// home_entity.dart
import 'package:equatable/equatable.dart';

class AvailableFiltersEntity extends Equatable {
  final List<String> colors;
  final List<String> sizes;

  const AvailableFiltersEntity({
    required this.colors,
    required this.sizes,
  });

  @override
  List<Object?> get props => [colors, sizes];
}

class BannerEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String? link;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    this.link,
  });

  @override
  List<Object?> get props => [id, title, subtitle, image, link];
}

class CategoryEntity extends Equatable {
  final String id;
  final String titleEn;
  final String titleAr;
  final num totalItemsNumber;
  final String image;
  final List<CategoryEntity> children;

  const CategoryEntity({
    required this.totalItemsNumber,
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.image,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;

  @override
  List<Object?> get props => [id, titleEn, titleAr, image, children, totalItemsNumber];
}

class ProductEntity extends Equatable {
  final String productId;
  final String titleEn;
  final String titleAr;
  final double price;
  final int discountPercentage;
  final List<String> images;
  final int stock;
  final String categoryId;
  final String categoryNameEn;
  final String categoryNameAr;
  final bool isWishlist;
  final num rating;
  final num reviewCount;
  final String? descriptionAr;
  final String? descriptionEn;
  final num? recommendationScore;
  final int? orderCount;

  const ProductEntity({
    required this.discountPercentage,
    required this.productId,
    required this.titleEn,
    required this.titleAr,
    required this.price,
    required this.images,
    required this.stock,
    required this.categoryId,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.isWishlist,
    required this.rating,
    required this.reviewCount,
    this.descriptionAr,
    this.descriptionEn,
    this.recommendationScore,
    this.orderCount,
  });

  @override
  List<Object?> get props => [
    productId,
    titleEn,
    titleAr,
    discountPercentage,
    price,
    images,
    stock,
    categoryId,
    categoryNameEn,
    categoryNameAr,
    isWishlist,
    rating,
    reviewCount,
    descriptionAr,
    descriptionEn,
    recommendationScore,
    orderCount,
  ];
}

class HomeEntity extends Equatable {
  final AvailableFiltersEntity availableFilters;
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<String> recentSearches;
  final List<ProductEntity> newArrivals;
  final List<ProductEntity> trendingProducts;
  final List<ProductEntity> recommendedProducts;
  final String userWishListId;

  const HomeEntity({
    required this.availableFilters,
    required this.userWishListId,
    required this.banners,
    required this.categories,
    required this.recentSearches,
    required this.newArrivals,
    required this.trendingProducts,
    required this.recommendedProducts,
  });

  @override
  List<Object?> get props => [
    availableFilters,
    userWishListId,
    banners,
    categories,
    recentSearches,
    newArrivals,
    trendingProducts,
    recommendedProducts,
  ];
}

extension HomeEntityCopyX on HomeEntity {
  HomeEntity copyWith({
    AvailableFiltersEntity? availableFilters,
    List<BannerEntity>? banners,
    List<CategoryEntity>? categories,
    List<String>? recentSearches,
    List<ProductEntity>? newArrivals,
    List<ProductEntity>? trendingProducts,
    List<ProductEntity>? recommendedProducts,
    String? userWishListId,
  }) {
    return HomeEntity(
      availableFilters: availableFilters ?? this.availableFilters,
      userWishListId: userWishListId ?? this.userWishListId,
      banners: List.unmodifiable(banners ?? this.banners),
      categories: List.unmodifiable(categories ?? this.categories),
      recentSearches: List.unmodifiable(recentSearches ?? this.recentSearches),
      newArrivals: List.unmodifiable(newArrivals ?? this.newArrivals),
      trendingProducts: List.unmodifiable(trendingProducts ?? this.trendingProducts),
      recommendedProducts: List.unmodifiable(recommendedProducts ?? this.recommendedProducts),
    );
  }
}

extension ProductEntityCopyX on ProductEntity {
  ProductEntity copyWith({
    String? productId,
    String? titleEn,
    String? titleAr,
    double? price,
    List<String>? images,
    int? stock,
    int? discountPercentage,
    String? categoryId,
    String? categoryNameEn,
    String? categoryNameAr,
    bool? isWishlist,
    num? rating,
    num? reviewCount,
    String? descriptionAr,
    String? descriptionEn,
    num? recommendationScore,
    int? orderCount,
  }) {
    return ProductEntity(
      discountPercentage: discountPercentage ?? this.discountPercentage,
      productId: productId ?? this.productId,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      price: price ?? this.price,
      images: List.unmodifiable(images ?? this.images),
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      isWishlist: isWishlist ?? this.isWishlist,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      recommendationScore: recommendationScore ?? this.recommendationScore,
      orderCount: orderCount ?? this.orderCount,
    );
  }
}