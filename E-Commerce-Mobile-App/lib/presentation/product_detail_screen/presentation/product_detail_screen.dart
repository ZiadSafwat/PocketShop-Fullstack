import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttermart/core/app_function/app_function.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../domain/entities/product_detail_entity.dart';
import './widgets/bottom_action_bar_widget.dart';
import './widgets/expandable_section_widget.dart';
import './widgets/product_image_carousel_widget.dart';
import './widgets/product_info_widget.dart';
import './widgets/product_options_widget.dart';
import './widgets/related_products_widget.dart';
import './widgets/reviews_section_widget.dart';
import 'bloc/product_detail_bloc.dart';


class ProductScreen extends StatefulWidget {
  const ProductScreen(
      {super.key, required this.productId, required this.wishListId, required this.blocContext});

  final String productId;
  final String wishListId;
  final BuildContext? blocContext ;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int selectedQuantity = 1;
  String selectedSize = '';
  String selectedColor = '';

  void _toggleWishlist(BuildContext context, bool isWishlist) {
    HapticFeedback.lightImpact();
final ctx=widget.blocContext??context;
    context.read<ProductDetailBloc>().add(
          FavEvent(widget.productId, !isWishlist, widget.wishListId, () {
            AppFunction.updatePrevPages(
                ctx, widget.productId, !isWishlist, widget.wishListId);
          }),
        );
  }

  void _shareProduct() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality would open here')),
    );
  }

  void _addToCart(ProductDetailEntity product) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.titleEn} to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () =>
              Navigator.pushNamed(context, '/shopping-cart-screen'),
        ),
      ),
    );
  }

  void _buyNow() {
    HapticFeedback.heavyImpact();
    Navigator.pushNamed(context, '/shopping-cart-screen');
  }

  @override
  void initState() {
    super.initState();
    context
        .read<ProductDetailBloc>()
        .add(FetchProductDetail(productId: widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        if (state is ProductDetailLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (state is ProductDetailError) {
          return Scaffold(body: Center(child: Text(state.message)));
        } else if (state is ProductDetailLoaded) {
          return _buildContent(state.productDetail);
        }
        return const Scaffold(body: SizedBox());
      },
    );
  }

  Widget _buildContent(ProductDetailEntity product) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60.h,
            pinned: true,
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            elevation: 0,
            leading: _buildAppBarButton(
              icon: 'arrow_back',
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _buildAppBarButton(icon: 'share', onTap: _shareProduct),
              _buildAppBarButton(
                icon: product.isWishlist ? 'favorite' : 'favorite_border',
                onTap: () => _toggleWishlist(context, product.isWishlist),
                isWishlisted: product.isWishlist,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImageCarouselWidget(
                  images: product.images
                      .map((e) => 'files/product/${product.productId}/$e')
                      .toList()),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  ProductInfoWidget(
                    name: product.titleEn,
                    price: product.price,
                    originalPrice: product.price /
                        (1 - (product.discountPercentage / 100)),
                    currency: "EGP",
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                    availability:
                        product.stock > 0 ? "In Stock" : "Out of Stock",
                  ),
                  SizedBox(height: 3.h),
                  ProductOptionsWidget(
                    sizes: product.size,
                    colors: product.colorEn,
                    selectedSize: selectedSize,
                    selectedColor: selectedColor,
                    quantity: selectedQuantity,
                    onSizeChanged: (size) {
                      HapticFeedback.selectionClick();
                      setState(() => selectedSize = size);
                    },
                    onColorChanged: (color) {
                      HapticFeedback.selectionClick();
                      setState(() => selectedColor = color);
                    },
                    onQuantityChanged: (quantity) {
                      HapticFeedback.selectionClick();
                      setState(() => selectedQuantity = quantity);
                    },
                  ),
                  SizedBox(height: 3.h),
                  ExpandableSectionWidget(
                    title: 'Description',
                    content: product.descriptionEn,
                    isExpanded: true,
                  ),
                  ExpandableSectionWidget(
                    title: 'Specifications',
                    content: "Category: ${product.categoryNameEn}\n"
                        "Stock: ${product.stock}",
                  ),
                  ExpandableSectionWidget(
                    title: 'Shipping Info',
                    content: "Delivery in 3-5 business days",
                  ),
                  SizedBox(height: 2.h),
                  ReviewsSectionWidget(
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                    reviews: product.reviews,
                  ),
                  SizedBox(height: 3.h),
                  RelatedProductsWidget(
                      products: product.relatedProducts,
                      wishListId: widget.wishListId),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBarWidget(
        onAddToCart: () => _addToCart(product),
        onBuyNow: _buyNow,
        price: product.price * selectedQuantity,
        currency: "EGP",
      ),
    );
  }

  Widget _buildAppBarButton({
    required String icon,
    required VoidCallback onTap,
    bool isWishlisted = false,
  }) {
    return Container(
      margin: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: CustomIconWidget(
          iconName: icon,
          color: isWishlisted
              ? Colors.red
              : AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }
}
