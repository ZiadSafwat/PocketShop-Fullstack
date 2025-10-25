import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../../../widgets/custom_image_widget.dart';
import '../../domain/entities/search_entity.dart';

class ProductCardWidget extends StatelessWidget {
  final SearchEntity product;
  final Function(Offset) onLongPress;
  final VoidCallback onWishlistTap;
  // final VoidCallback(SearchEntity) onTap;
  final void Function(SearchEntity) onTap;
  const ProductCardWidget({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onLongPress,
    required this.onWishlistTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isWishlisted = product.isWishlist;
    final double price = product.price;
    final double discountPercentage = product.discountPercentage;
    final double rating = product.rating;
    final int reviewCount = product.reviewCount;
    final bool inStock = product.stock > 0;

    final double discountedPrice =
        discountPercentage > 0 ? price * (1 - discountPercentage / 100) : price;

    return GestureDetector(
      onTap: () => onTap(product),
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          height: 30.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image with wishlist button
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CustomImageWidget(
                        imageUrl: product.images.isNotEmpty
                            ? 'files/product/${product.productId}/${product.images.first}'
                            : '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Discount badge
                    discountPercentage > 0
                        ? Positioned(
                            top: 2.w,
                            left: 2.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 1.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${discountPercentage.toStringAsFixed(0)}%',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),

                    // Wishlist button
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: InkWell(
                        onTap: onWishlistTap,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName:
                                isWishlisted ? 'favorite' : 'favorite_border',
                            color: isWishlisted
                                ? AppTheme.lightTheme.colorScheme.error
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // Out of stock overlay
                    !inStock
                        ? Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                              ),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Out of Stock',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),

              // Product details
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.titleEn,
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 1.h),

                      // Rating
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return CustomIconWidget(
                              iconName: index < rating.floor()
                                  ? 'star'
                                  : 'star_border',
                              color: index < rating.floor()
                                  ? Colors.amber
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              size: 12,
                            );
                          }),
                          SizedBox(width: 1.w),
                          Text(
                            '($reviewCount)',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price
                      Row(
                        children: [
                          Text(
                            '\$${discountedPrice.toStringAsFixed(2)}',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                          discountPercentage > 0
                              ? Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 2.w),
                                      Text(
                                        '\$${price.toStringAsFixed(2)}',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
