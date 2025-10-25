// lib/presentation/shopping_cart_screen/shopping_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttermart/core/app_export.dart';
import 'package:fluttermart/core/di/injection_container.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/cart_item_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/empty_cart_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/order_summary_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/promo_code_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/recently_removed_banner_widget.dart';
import 'package:sizer/sizer.dart';
import '../domain/entities/cart_item_entity.dart';
import 'bloc/cart_bloc.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CartBloc>()..add(LoadCartEvent()),
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Shopping Cart',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: AppTheme.lightTheme.appBarTheme.elevation,
          actions: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoaded && state.items.isNotEmpty) {
                  return TextButton(
                    onPressed: () {
                      context.read<CartBloc>().add(ClearCartEvent());
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CartError) {
              return Center(child: Text(state.message));
            } else if (state is CartLoaded) {
              return _buildCartContent(context, state);
            } else {
              return const EmptyCartWidget(
                onStartShopping: _navigateToProductBrowse,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    return Column(
      children: [
        // Recently removed banner
        if (state.recentlyRemovedItem != null)
          RecentlyRemovedBannerWidget(
            itemName: state.recentlyRemovedItem!,
            onUndo: () {
              // Implement undo logic
            },
            onDismiss: () {
              // Clear the recently removed item
              context.read<CartBloc>().add(LoadCartEvent());
            },
          ),

        // Cart items list
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                // Cart items count
                Text(
                  '${state.items.length} ${state.items.length == 1 ? 'item' : 'items'} in cart',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),

                // Cart items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return CartItemWidget(
                      item: item.toJson(),
                      onQuantityChanged: (newQuantity) {
                        context.read<CartBloc>().add(
                          UpdateQuantityEvent(
                            itemId: item.id,
                            newQuantity: newQuantity,
                          ),
                        );
                      },
                      onRemove: () {
                        context.read<CartBloc>().add(
                          RemoveItemEvent(
                            itemId: item.id,
                            itemName: item.name,
                          ),
                        );
                      },
                      onMoveToWishlist: () {
                        // Implement move to wishlist
                      },
                      onSaveForLater: () {
                        // Implement save for later
                      },
                      onViewProduct: () {
                        Navigator.pushNamed(context, '/product-detail-screen');
                      },
                    );
                  },
                ),

                SizedBox(height: 3.h),

                // Promo code section
                PromoCodeWidget(
                  isExpanded: false, // You'll need to manage this state
                  onToggle: () {
                    // Toggle promo code expansion
                  },
                ),

                SizedBox(height: 3.h),

                // Order summary
                OrderSummaryWidget(
                  subtotal: _calculateSubtotal(state.items),
                  tax: _calculateTax(state.items),
                  shipping: _calculateShipping(state.items),
                  total: _calculateTotal(state.items),
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _calculateSubtotal(List<CartItemEntity> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double _calculateTax(List<CartItemEntity> items) {
    return _calculateSubtotal(items) * 0.08;
  }

  double _calculateShipping(List<CartItemEntity> items) {
    return _calculateSubtotal(items) > 50 ? 0.0 : 5.99;
  }

  double _calculateTotal(List<CartItemEntity> items) {
    return _calculateSubtotal(items) + _calculateTax(items) + _calculateShipping(items);
  }

  static void _navigateToProductBrowse() {
    // Implement navigation to product browse
  }
}