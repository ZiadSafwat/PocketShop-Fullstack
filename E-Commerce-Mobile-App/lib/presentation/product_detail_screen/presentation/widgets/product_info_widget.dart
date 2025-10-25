import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class ProductInfoWidget extends StatelessWidget {
  final String name;
  final double price;
  final double originalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final String availability;

  const ProductInfoWidget({
    super.key,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.currency,
    required this.rating,
    required this.reviewCount,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = originalPrice > price;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                '${price.toStringAsFixed(1)}$currency',
                style: AppTheme.getPriceTextStyle(
                  isLight: true,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ).copyWith(overflow: TextOverflow.ellipsis,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              if (hasDiscount) ...[
                SizedBox(width: 2.w),
                Text(
                  '$currency${originalPrice.toStringAsFixed(2)}',
                  style: AppTheme.getPriceTextStyle(
                    isLight: true,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ).copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(((originalPrice - price) / originalPrice) * 100).round()}% OFF',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return CustomIconWidget(
                    iconName: index < rating.floor()
                        ? 'star'
                        : index < rating
                            ? 'star_half'
                            : 'star_border',
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              SizedBox(width: 2.w),
              Text(
                rating.toStringAsFixed(1),
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                '($reviewCount reviews)',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: availability == 'In Stock'
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                availability,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: availability == 'In Stock'
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
