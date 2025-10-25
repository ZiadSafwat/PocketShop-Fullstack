// home_response_model.dart
import '../../domain/entities/home_entity.dart';
import 'dart:convert';

class AvailableFiltersModel extends AvailableFiltersEntity {
  const AvailableFiltersModel({
    required super.colors,
    required super.sizes,
  });

  factory AvailableFiltersModel.fromJson(Map<String, dynamic> json) {
    return AvailableFiltersModel(
      colors: List<String>.from(json['colors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'colors': colors,
    'sizes': sizes,
  };
}

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.image,
    super.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: _parseImage(json['id'], json['image']),
      link: json['link'],
    );
  }

  static String _parseImage(String recordId, dynamic imageData) {
    if (imageData == null) return '';

    if (imageData is String) {
      return 'files/banner/$recordId/$imageData';
    } else if (imageData is List && imageData.isNotEmpty) {
      return 'files/banner/$recordId/${imageData.first}';
    }
    return '';
  }

  static String _deParseImage(String image) {
    return image.split('/').last;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'image': _deParseImage(image),
    'link': link,
  };
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.titleEn,
    required super.titleAr,
    required super.image,
    required super.totalItemsNumber,
    super.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final titleMap = json['title'] as Map<String, dynamic>? ?? {};
    return CategoryModel(
      id: json['id'] ?? '',
      titleEn: titleMap['en']?.toString() ?? '',
      titleAr: titleMap['ar']?.toString() ?? '',
      image: _parseImage(json['id'], json['image']),
      children: (json['children'] as List?)
          ?.map((e) => CategoryModel.fromJson(e))
          .toList() ??
          const [],
      totalItemsNumber: json['totalItemsNumber'] ?? 0,
    );
  }

  static String _parseImage(String recordId, dynamic imageData) {
    if (imageData == null) return '';

    if (imageData is List && imageData.isNotEmpty) {
      return 'files/categories/$recordId/${imageData.first}';
    }
    return '';
  }

  static String _deParseImage(String image) {
    return image.split('/').last;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': {'en': titleEn, 'ar': titleAr},
    'image': [_deParseImage(image)],
    'totalItemsNumber': totalItemsNumber,
    'children': children.map((child) => (child as CategoryModel).toJson()).toList(),
  };
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.productId,
    required super.titleEn,
    required super.titleAr,
    required super.price,
    required super.discountPercentage,
    required super.images,
    required super.stock,
    required super.categoryId,
    required super.categoryNameEn,
    required super.categoryNameAr,
    required super.isWishlist,
    required super.rating,
    required super.reviewCount,
    super.descriptionAr,
    super.descriptionEn,
    super.recommendationScore,
    super.orderCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: _parseImages(json['productId'] ?? '', json['image']),
      stock: json['stock'] ?? 0,
      discountPercentage: json['discountPercentage'] ?? 0,
      categoryId: json['category'] ?? '',
      categoryNameEn: json['category_name_en'] ?? '',
      categoryNameAr: json['category_name_ar'] ?? '',
      isWishlist: json['is_wishlist'] ?? false,
      rating: json['rating'] ?? 0,
      reviewCount: json['review_count'] ?? 0,
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      recommendationScore: json['recommendation_score'],
      orderCount: json['orderCount'],
    );
  }

  static List<String> _parseImages(String recordId, dynamic imageData) {
    if (imageData == null) return [];

    try {
      final List<dynamic> parsedList = switch (imageData) {
        String _ => jsonDecode(imageData) as List? ?? [],
        List _ => imageData,
        _ => [],
      };

      return parsedList
          .map((e) => e?.toString())
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .map((e) => 'files/product/$recordId/$e')
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<String> _deParseImages(List<String> images) {
    return images.map((fullPath) {
      final segments = fullPath.split('/');
      return segments.last;
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'discountPercentage': discountPercentage,
      'title_en': titleEn,
      'title_ar': titleAr,
      'price': price,
      'image': _deParseImages(images),
      'stock': stock,
      'category': categoryId,
      'category_name_en': categoryNameEn,
      'category_name_ar': categoryNameAr,
      'is_wishlist': isWishlist,
      'rating': rating,
      'review_count': reviewCount,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'recommendation_score': recommendationScore,
      'orderCount': orderCount,
    };
  }
}

class HomeResponseModel extends HomeEntity {
  const HomeResponseModel({
    required super.availableFilters,
    required super.banners,
    required super.categories,
    required super.recentSearches,
    required super.newArrivals,
    required super.trendingProducts,
    required super.recommendedProducts,
    required super.userWishListId,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return HomeResponseModel(
      availableFilters: _parseAvailableFilters(data['available_filters']),
      banners: _parseBanners(data['banners']),
      categories: _parseCategories(data['categories']),
      recentSearches: _parseRecentSearches(data['recentSearches']),
      newArrivals: _parseProducts(data['new_arrivals']),
      trendingProducts: _parseProducts(data['trending_products']),
      recommendedProducts: _parseProducts(data['recommendations']),
      userWishListId: data['userWishListId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'data': {
      'available_filters': (availableFilters as AvailableFiltersModel).toJson(),
      'userWishListId': userWishListId,
      'banners': banners.map((b) => (b as BannerModel).toJson()).toList(),
      'categories': categories.map((c) => (c as CategoryModel).toJson()).toList(),
      'recentSearches': recentSearches.map((q) => {'search_query': q}).toList(),
      'new_arrivals': newArrivals.map(_productToJson).toList(),
      'trending_products': trendingProducts.map(_productToJson).toList(),
      'recommendations': recommendedProducts.map(_productToJson).toList(),
    },
    'success': true,
  };

  // ---- parsers ----
  static AvailableFiltersModel _parseAvailableFilters(dynamic filters) {
    if (filters is Map<String, dynamic>) {
      return AvailableFiltersModel.fromJson(filters);
    }
    return const AvailableFiltersModel(colors: [], sizes: []);
  }

  static List<String> _parseRecentSearches(dynamic searches) {
    if (searches is List) {
      return searches
          .map((e) => (e as Map?)?['search_query']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static List<ProductModel> _parseProducts(dynamic products) {
    if (products is List) {
      return products
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  static List<BannerModel> _parseBanners(dynamic banners) {
    if (banners is List) {
      return banners
          .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  static List<CategoryModel> _parseCategories(dynamic cats) {
    if (cats is List) {
      return cats
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  static Map<String, dynamic> _productToJson(ProductEntity e) {
    if (e is ProductModel) return e.toJson();
    return ProductModel(
      discountPercentage: e.discountPercentage,
      productId: e.productId,
      titleEn: e.titleEn,
      titleAr: e.titleAr,
      price: e.price,
      images: e.images,
      stock: e.stock,
      categoryId: e.categoryId,
      categoryNameEn: e.categoryNameEn,
      categoryNameAr: e.categoryNameAr,
      isWishlist: e.isWishlist,
      rating: e.rating,
      reviewCount: e.reviewCount,
      descriptionAr: e.descriptionAr,
      descriptionEn: e.descriptionEn,
      recommendationScore: e.recommendationScore,
      orderCount: e.orderCount,
    ).toJson();
  }
}

extension HomeResponseModelCopyX on HomeResponseModel {
  HomeResponseModel copyWith({
    AvailableFiltersEntity? availableFilters,
    List<BannerEntity>? banners,
    List<CategoryEntity>? categories,
    List<String>? recentSearches,
    List<ProductEntity>? newArrivals,
    List<ProductEntity>? trendingProducts,
    List<ProductEntity>? recommendedProducts,
    String? userWishListId,
  }) {
    return HomeResponseModel(
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