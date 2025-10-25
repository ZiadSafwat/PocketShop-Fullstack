import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/home_entity.dart';
import './product_card_widget.dart';
import '../bloc/home_bloc.dart'; // Import your bloc

class ProductSectionWidget extends StatelessWidget {
  final String title;
  final List<ProductEntity> products;
  final Function(ProductEntity) onProductTap;
  final String wishListId;
  final String type;

  const ProductSectionWidget({
    super.key,
    required this.title,
    required this.products,
    required this.onProductTap,
    required this.wishListId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/product-browse-screen');
                  },
                  child: Text(
                    'View All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          // Horizontal product list
          SizedBox(
            height: 32.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  width: 45.w,
                  margin: EdgeInsets.only(right: 3.w),
                  child: ProductCardWidget(
                    product: product,
                    wishListId: wishListId,type: type,
                    onTap: () => onProductTap(product),
                    onQuickAdd: () => _onQuickAdd(context, product),
                    onShareTap: () => _onShareTap(context, product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onQuickAdd(BuildContext context, ProductEntity product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.titleAr} added to cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onShareTap(BuildContext context, ProductEntity product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${product.titleAr}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}