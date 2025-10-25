// search_response_model.dart
import '../../domain/entities/search_entity.dart';

class SearchResponseModel {
  final bool success;
  final List<SearchProductModel> data;
  final PaginationModel pagination;

  SearchResponseModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((product) => product.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => SearchProductModel.fromJson(item))
          .toList() ??
          [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;

  PaginationModel({
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'itemsPerPage': itemsPerPage,
      'totalItems': totalItems,
      'totalPages': totalPages,
    };
  }

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] ?? 1,
      itemsPerPage: json['itemsPerPage'] ?? 10,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class SearchProductModel {
  final String productId;
  final String titleEn;
  final String titleAr;
  final double price;
  final List<String> images;
  final String descriptionEn;
  final String descriptionAr;
  final int stock;
  final double discountPercentage;
  final List<String> categoryIds;
  final List<String> categoryNamesEn;
  final List<String> categoryNamesAr;
  final double rating;
  final int reviewCount;
  final bool isWishlist;
  final String userId;
  final String userWishListId;
  final List<String> colorsEn;
  final List<String> colorsAr;
  final List<String> sizes;

  SearchProductModel({
    required this.productId,
    required this.titleEn,
    required this.titleAr,
    required this.price,
    required this.images,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.stock,
    required this.discountPercentage,
    required this.categoryIds,
    required this.categoryNamesEn,
    required this.categoryNamesAr,
    required this.rating,
    required this.reviewCount,
    required this.isWishlist,
    required this.userId,
    required this.userWishListId,
    required this.colorsEn,
    required this.colorsAr,
    required this.sizes,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title_en': titleEn,
      'title_ar': titleAr,
      'price': price,
      'image': images,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'stock': stock,
      'discountPercentage': discountPercentage,
      'categories': categoryIds,
      'category_names_en': categoryNamesEn,
      'category_names_ar': categoryNamesAr,
      'rating': rating,
      'review_count': reviewCount,
      'is_wishlist': isWishlist,
      'userId': userId,
      'userWishListId': userWishListId,
      'colors_en': colorsEn,
      'colors_ar': colorsAr,
      'sizes': sizes,
    };
  }

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {
    // Helper function to handle a list of string values
    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return List<String>.from(value.whereType<String>());
      }
      return [];
    }

    // Helper function to handle the nested image array
    List<String> parseImages(dynamic value) {
      if (value is List && value.isNotEmpty) {
        // Handle nested array structure
        if (value[0] is List) {
          return parseStringList(value[0]);
        } else {
          return parseStringList(value);
        }
      }
      return [];
    }

    return SearchProductModel(
      productId: json['productId'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: parseImages(json['image']),
      descriptionEn: json['description_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      categoryIds: parseStringList(json['categories']),
      categoryNamesEn: parseStringList(json['category_names_en']),
      categoryNamesAr: parseStringList(json['category_names_ar']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isWishlist: json['is_wishlist'] ?? false,
      userId: json['userId'] ?? '',
      userWishListId: json['userWishListId'] ?? '',
      colorsEn: parseStringList(json['colors_en']),
      colorsAr: parseStringList(json['colors_ar']),
      sizes: parseStringList(json['sizes']),
    );
  }

  SearchEntity toEntity() {
    return SearchEntity(
      productId: productId,
      titleEn: titleEn,
      titleAr: titleAr,
      price: price,
      images: images,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      stock: stock,
      discountPercentage: discountPercentage,
      categoryId: categoryIds.isNotEmpty ? categoryIds.first : null,
      categoryNameEn: categoryNamesEn.isNotEmpty ? categoryNamesEn.first : null,
      categoryNameAr: categoryNamesAr.isNotEmpty ? categoryNamesAr.first : null,
      rating: rating,
      reviewCount: reviewCount,
      isWishlist: isWishlist,
      userId: userId,
      userWishListId: userWishListId,
      // Add the new properties
      sizes: sizes,
      colorsEn: colorsEn,
      colorsAr: colorsAr,
    );
  }
}