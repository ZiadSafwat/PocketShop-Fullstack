import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../../../widgets/custom_image_widget.dart';
import '../../domain/entities/home_entity.dart';
import '../bloc/home_bloc.dart';

class ProductCardWidget extends StatefulWidget {
  final String wishListId;
  final String type;
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onQuickAdd;
  final VoidCallback? onShareTap;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.type,
    this.onTap,
    this.onQuickAdd,
    this.onShareTap,
    required this.wishListId,
  });

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  bool _showQuickActions = false;

  void _showQuickActionsMenu() {
    setState(() {
      _showQuickActions = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showQuickActions = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wishListId = widget.wishListId;
    final type = widget.type;
    final isOnSale = (product.discountPercentage ?? 0) > 0;
    final rating = product.rating;
    final reviews = product.reviewCount as int? ?? 0;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Use an efficient check for the loading state of a specific item
        final isFavLoading = false;//state is HomeLoaded && state.favLoadingItemId == product.productId;

        return GestureDetector(
          onTap: widget.onTap,
          onLongPress: _showQuickActionsMenu,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Stack(
                            children: [
                              CustomImageWidget(
                                imageUrl: (product.images.isNotEmpty) ? product.images.first : null,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              if (isOnSale)
                                Positioned(
                                  top: 2.w,
                                  left: 2.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.colorScheme.error,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'SALE',
                                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 2.w,
                                right: 2.w,
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isFavLoading) {
                                      context.read<HomeBloc>().add(
                                        FavEvent(
                                          product.productId,
                                          !product.isWishlist,
                                          wishListId,
                                          type,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(1.5.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: isFavLoading
                                        ? SizedBox(
                                      width: 4.w,
                                      height: 4.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.lightTheme.colorScheme.primary,
                                      ),
                                    )
                                        : CustomIconWidget(
                                      iconName: product.isWishlist ? 'favorite' : 'favorite_border',
                                      color: product.isWishlist ? AppTheme.lightTheme.colorScheme.error : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                      size: 4.w,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.titleAr,
                              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: Colors.amber,
                                  size: 3.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '($reviews)',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${(product.price * (1 - (product.discountPercentage ?? 0) / 100)).toStringAsFixed(2)}\$',
                                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.lightTheme.colorScheme.primary,
                                        ),
                                      ),
                                      if (isOnSale)
                                        Text(
                                          '${product.price.toStringAsFixed(2)}\$',
                                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                            decoration: TextDecoration.lineThrough,
                                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: widget.onQuickAdd,
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'add',
                                      color: Colors.white,
                                      size: 4.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showQuickActions)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickActionButton(
                            icon: 'favorite_border',
                            label: 'Wishlist',
                            onTap: () {
                              context.read<HomeBloc>().add(
                                FavEvent(
                                  product.productId,
                                  !product.isWishlist,
                                  wishListId,
                                  type,
                                ),
                              );
                              setState(() {
                                _showQuickActions = false;
                              });
                            },
                          ),
                          SizedBox(height: 2.h),
                          _buildQuickActionButton(
                            icon: 'share',
                            label: 'Share',
                            onTap: widget.onShareTap,
                          ),
                          SizedBox(height: 2.h),
                          _buildQuickActionButton(
                            icon: 'search',
                            label: 'Similar',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Finding similar products...')),
                              );
                              setState(() {
                                _showQuickActions = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required String icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}