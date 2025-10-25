import 'package:flutter/material.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/cart_item_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/empty_cart_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/order_summary_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/promo_code_widget.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/widgets/recently_removed_banner_widget.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../theme/app_theme.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isPromoExpanded = false;
  bool _showRecentlyRemoved = false;
  String? _recentlyRemovedItem;

  // Mock cart data
  List<Map<String, dynamic>> cartItems = [
    {
      "id": 1,
      "name": "Premium Cotton T-Shirt",
      "image":
          "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop",
      "price": 29.99,
      "originalPrice": 39.99,
      "quantity": 2,
      "size": "M",
      "color": "Navy Blue",
      "inStock": true,
    },
    {
      "id": 2,
      "name": "Wireless Bluetooth Headphones",
      "image":
          "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop",
      "price": 89.99,
      "originalPrice": 129.99,
      "quantity": 1,
      "size": null,
      "color": "Black",
      "inStock": true,
    },
    {
      "id": 3,
      "name": "Leather Wallet",
      "image":
          "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop",
      "price": 45.00,
      "originalPrice": 60.00,
      "quantity": 1,
      "size": null,
      "color": "Brown",
      "inStock": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get subtotal {
    return cartItems.fold(
        0.0,
        (sum, item) =>
            sum + ((item['price'] as double) * (item['quantity'] as int)));
  }

  double get tax {
    return subtotal * 0.08; // 8% tax
  }

  double get shipping {
    return subtotal > 50 ? 0.0 : 5.99;
  }

  double get total {
    return subtotal + tax + shipping;
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  void _updateQuantity(int itemId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _removeItem(itemId);
      } else {
        final itemIndex = cartItems.indexWhere((item) => item['id'] == itemId);
        if (itemIndex != -1) {
          cartItems[itemIndex]['quantity'] = newQuantity;
        }
      }
    });
  }

  void _removeItem(int itemId) {
    setState(() {
      final itemIndex = cartItems.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        final removedItem = cartItems.removeAt(itemIndex);
        _recentlyRemovedItem = removedItem['name'] as String;
        _showRecentlyRemoved = true;

        // Hide banner after 10 seconds
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _showRecentlyRemoved = false;
            });
          }
        });
      }
    });
  }

  void _undoRemove() {
    setState(() {
      _showRecentlyRemoved = false;
      // In a real app, you would restore the item from a temporary storage
    });
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear Cart',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to remove all items from your cart?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  cartItems.clear();
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _moveToWishlist(int itemId) {
    // Mock implementation
    _removeItem(itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item moved to wishlist'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveForLater(int itemId) {
    // Mock implementation
    _removeItem(itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item saved for later'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewProduct(int itemId) {
    Navigator.pushNamed(context, '/product-detail-screen');
  }

  void _proceedToCheckout() {
    if (cartItems.isEmpty) return;

    // Check if user is logged in (mock check)
    bool isLoggedIn = false; // This would come from your auth state

    if (!isLoggedIn) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Login Required',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            content: Text(
              'Please login to continue with checkout. Your cart will be preserved.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/login-screen');
                },
                child: const Text('Login'),
              ),
            ],
          );
        },
      );
    } else {
      // Proceed to checkout
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proceeding to checkout...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(width: 2.w),
        ],
      ),
      body: cartItems.isEmpty
          ? EmptyCartWidget(
              onStartShopping: () =>
                  Navigator.pushNamed(context, '/product-browse-screen'),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Recently removed banner
                  if (_showRecentlyRemoved)
                    RecentlyRemovedBannerWidget(
                      itemName: _recentlyRemovedItem ?? '',
                      onUndo: _undoRemove,
                      onDismiss: () {
                        setState(() {
                          _showRecentlyRemoved = false;
                        });
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
                            '$totalItems ${totalItems == 1 ? 'item' : 'items'} in cart',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Cart items
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 2.h),
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return CartItemWidget(
                                item: item,
                                onQuantityChanged: (newQuantity) {
                                  _updateQuantity(
                                      item['id'] as int, newQuantity);
                                },
                                onRemove: () => _removeItem(item['id'] as int),
                                onMoveToWishlist: () =>
                                    _moveToWishlist(item['id'] as int),
                                onSaveForLater: () =>
                                    _saveForLater(item['id'] as int),
                                onViewProduct: () =>
                                    _viewProduct(item['id'] as int),
                              );
                            },
                          ),

                          SizedBox(height: 3.h),

                          // Promo code section
                          PromoCodeWidget(
                            isExpanded: _isPromoExpanded,
                            onToggle: () {
                              setState(() {
                                _isPromoExpanded = !_isPromoExpanded;
                              });
                            },
                          ),

                          SizedBox(height: 3.h),

                          // Order summary
                          OrderSummaryWidget(
                            subtotal: subtotal,
                            tax: tax,
                            shipping: shipping,
                            total: total,
                          ),

                          SizedBox(height: 10.h), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: AppTheme.lightTheme.elevatedButtonTheme.style,
                    child: Text(
                      'Checkout • \$${total.toStringAsFixed(2)}',
                      style: AppTheme
                              .lightTheme.elevatedButtonTheme.style?.textStyle
                              ?.resolve({}) ??
                          AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
