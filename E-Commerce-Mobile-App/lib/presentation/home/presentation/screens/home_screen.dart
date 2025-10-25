import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttermart/core/app_export.dart';
import '../../domain/entities/home_entity.dart';
import '../bloc/home_bloc.dart';
import '../widgets/category_grid_widget.dart';
import '../widgets/hero_banner_widget.dart';
import '../widgets/product_section_widget.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
     context.read<HomeBloc>().add(FetchHomeData());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const _HomeScreenContent();
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  void _onBottomNavTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        break; // Already on home
      case 1:
        Navigator.pushNamed(context, '/product-browse-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/shopping-cart-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile-screen');
        break;
    }
  }

  void _onProductTap(BuildContext context, ProductEntity product,String wishListId) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetailScreen,
      arguments: {'productId': product.productId,'wishListId':wishListId},
    );


  }

  void _onSearchTap(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Search functionality coming soon!')),
    // );
    Navigator.pushNamed(context, '/product-browse-screen');

  }

  void _onNotificationTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No new notifications')),
    );
  }

  void _onCartTap(BuildContext context) {
    Navigator.pushNamed(context, '/shopping-cart-screen');
  }

  void _onScanTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barcode scanner opening...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cartItemCount = 3; // Should come from CartBloc

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FlutterMart',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _onNotificationTap(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'notifications_outlined',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: () => _onCartTap(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                ),
              ),
              child: Stack(
                children: [
                  CustomIconWidget(
                    iconName: 'shopping_cart_outlined',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 4.w,
                          minHeight: 4.w,
                        ),
                        child: Text(
                          cartItemCount.toString(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: 8.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 3.w),
        ],
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeError) {
              return Center(child: Text(state.message));
            } else if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(RefreshHomeData());
                },
                child: _buildHomeContent(context, state),
              );
            }
            return const SizedBox(); // Initial state
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _onBottomNavTap(index, context),
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            AppTheme.lightTheme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            AppTheme.lightTheme.bottomNavigationBarTheme.unselectedItemColor,
        selectedLabelStyle:
            AppTheme.lightTheme.bottomNavigationBarTheme.selectedLabelStyle,
        unselectedLabelStyle:
            AppTheme.lightTheme.bottomNavigationBarTheme.unselectedLabelStyle,
        elevation:
            AppTheme.lightTheme.bottomNavigationBarTheme.elevation ?? 8.0,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.selectedItemColor!,
              size: 6.w,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search_outlined',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
              size: 6.w,
            ),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'shopping_cart_outlined',
                  color: AppTheme
                      .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
                  size: 6.w,
                ),
                if (cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(0.5.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 3.w,
                        minHeight: 3.w,
                      ),
                      child: Text(
                        cartItemCount.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 7.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person_outlined',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
              size: 6.w,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    return CustomScrollView(
      slivers: [
        if (state.homeData.recentSearches.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildRecentSearches(context, state),
          ),
        SliverToBoxAdapter(
            child: HeroBannerWidget(
          banners: state.homeData.banners,
        )),
        SliverToBoxAdapter(
            child: CategoryGridWidget(
          categories: state.homeData.categories,
        )),
        SliverToBoxAdapter(
          child: ProductSectionWidget(
            title: 'New Arrivals',
            type: 'Arrivals',
            wishListId: state.homeData.userWishListId,
            products: state.homeData.newArrivals,
            onProductTap: (product) => _onProductTap(context, product,state.homeData.userWishListId),
          ),
        ),
        SliverToBoxAdapter(
          child: ProductSectionWidget(
            title: 'Trending Now',
            type: 'Trending',
            wishListId: state.homeData.userWishListId,
            products: state.homeData.trendingProducts,
            onProductTap: (product) => _onProductTap(context, product,state.homeData.userWishListId),
          ),
        ),
        SliverToBoxAdapter(
          child: ProductSectionWidget(
            type: 'Recommended',
            wishListId: state.homeData.userWishListId,
            title: 'Recommended for You',
            products: state.homeData.recommendedProducts,
            onProductTap: (product) => _onProductTap(context, product,state.homeData.userWishListId),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context, HomeLoaded state) {
    final bloc = context.read<HomeBloc>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBarWidget(
            onTap: () => _onSearchTap(context),
            onScanTap: () => _onScanTap(context),
          ),
          SizedBox(height: 1.h),
          Text(
            'Recent Searches',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: state.homeData.recentSearches.map((search) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      search,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () => bloc.add(RemoveSearchEvent(search)),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
