import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../routes/app_routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../../../widgets/custom_image_widget.dart';
import '../../domain/entities/product_detail_entity.dart';

class RelatedProductsWidget extends StatelessWidget {
  final List<RelatedProductEntity> products;
final String wishListId;
  const RelatedProductsWidget({
    super.key,
    required this.products, required this.wishListId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You might also like',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
               ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 32.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product,wishListId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, RelatedProductEntity product,String wishListId) {
    return Container(
      width: 40.w,
      margin: EdgeInsets.only(right: 3.w),
      child: GestureDetector(
        onTap: () {
          Navigator.popAndPushNamed(
            context,
            AppRoutes.productDetailScreen,
            arguments: {'productId': product.productId,'wishListId':wishListId},
          );
        },
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              SizedBox(
                height: 16.h, // Fixed height for image
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CustomImageWidget(

                    imageUrl:'files/product/${product.productId}/${product.images .first}'
                    ,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Content section with constrained height
              Container(
                height: 12.h, // Fixed height for content
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.titleAr,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (starIndex) {
                            final rating = product.rating;
                            return CustomIconWidget(
                              iconName: starIndex < rating.floor()
                                  ? 'star'
                                  : starIndex < rating
                                  ? 'star_half'
                                  : 'star_border',
                              color: Colors.amber,
                              size: 10, // Reduced size
                            );
                          }),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 10.sp, // Smaller font size
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${product.price.toStringAsFixed(1)} EGP',
                      style: AppTheme.getPriceTextStyle(
                        isLight: true,
                        fontSize: 12.sp, // Smaller font size
                        fontWeight: FontWeight.w600,
                      ).copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}