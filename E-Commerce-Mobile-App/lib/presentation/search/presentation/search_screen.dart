import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttermart/presentation/search/presentation/widgets/filter_modal_widget.dart';
import 'package:fluttermart/presentation/search/presentation/widgets/product_card_widget.dart';
import 'package:fluttermart/presentation/search/presentation/widgets/sort_bottom_sheet_widget.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_function/app_function.dart';
import '../../../core/di/injection_container.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../home/presentation/bloc/home_bloc.dart' as home;
import '../data/models/search_response_model.dart';
import '../domain/entities/search_entity.dart';
import 'bloc/search_bloc.dart';
import 'bloc/search_event.dart';
import 'bloc/search_state.dart';
import 'widgets/filter_chip_widget.dart';

class ProductBrowseScreen extends StatefulWidget {
  const ProductBrowseScreen({super.key, this.withCategories});
  final List<String>? withCategories;
  @override
  State<ProductBrowseScreen> createState() => _ProductBrowseScreenState();
}

class _ProductBrowseScreenState extends State<ProductBrowseScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late SearchBloc _searchBloc;

  bool _isLoadingMore = false;
  List<String> _activeFilters = [];
  int _filterCount = 0;
  String _sortBy = 'Relevance';

  // Filter state variables
  String orderBy = 'title_en';
  String orderDirection = 'ASC';
  double minPrice = 0;
  double maxPrice = 100000;
  double minRating = 0;
  List<String> categories = [];
  List<String> sizes = [];
  List<String> colors = [];
  String userWishList = '';

  // Page navigation state
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<SearchBloc>();
    if (BlocProvider.of<home.HomeBloc>(context).state is home.HomeLoaded) {
      final homeBloc =
          BlocProvider.of<home.HomeBloc>(context).state as home.HomeLoaded;
      userWishList = homeBloc.homeData.userWishListId;
    }
    // Load initial data
    _searchBloc.add(SearchProductsEvent(
        query: '', category: (widget.withCategories ?? []).join(',')));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _performSearch();
  }

  void _toggleWishlist(
      String userWishList, String productId, bool isFav, bool isFake,BuildContext ctx) {
    _searchBloc

        .add(SearchUpdateFavEvent(productId, userWishList, !isFav, isFake, () {
      AppFunction.updatePrevPages(ctx, productId, !isFav, userWishList);
    }));
  }

  void _removeFilter(String filter, int index) {
    setState(() {
      _activeFilters.remove(filter);
      _filterCount = _activeFilters.length;

      if (filter.startsWith('Category: ')) {
        filter.replaceFirst('Category: ', '');
        categories.removeAt(index);
      } else if (filter.startsWith('Color: ')) {
        colors.remove(filter.replaceFirst('Color: ', ''));
      } else if (filter.startsWith('Size: ')) {
        sizes.remove(filter.replaceFirst('Size: ', ''));
      } else if (filter.startsWith('Price: ')) {
        minPrice = 0;
        maxPrice = 100000;
      } else if (filter.startsWith('Rating: ')) {
        minRating = 0;
      }
    });
    _performSearch();
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _filterCount = 0;
      minPrice = 0;
      maxPrice = 100000;
      minRating = 0;
      categories.clear();
      sizes.clear();
      colors.clear();
    });
    _searchBloc.add(SearchProductsEvent(query: ''));
  }

  void _performSearch() {
    setState(() {
      _isLoadingMore = false;
      _currentPage = 1; // Reset to first page on new search
    });

    _searchBloc.add(SearchProductsEvent(
        query: _searchController.text,
        orderBy: orderBy,
        orderDirection: orderDirection,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        category: categories.isNotEmpty ? categories.join(',') : null,
        sizes: sizes.isNotEmpty ? sizes : null,
        colors: colors.isNotEmpty ? colors : null));
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;

    setState(() {
      _currentPage = page;
      _isLoadingMore = true;
    });

    _searchBloc.add(SearchProductsEvent(
        query: _searchController.text,
        orderBy: orderBy,
        orderDirection: orderDirection,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        category: categories.isNotEmpty ? categories.join(',') : null,
        sizes: sizes.isNotEmpty ? sizes : null,
        colors: colors.isNotEmpty ? colors : null,
        offset: page));
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalWidget(
        activeFilters: _activeFilters,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        selectedCategories: categories,
        selectedSizes: sizes,
        selectedColors: colors,
        onFiltersChanged: (newFilters, newMinPrice, newMaxPrice, newMinRating,
            newCategories, newSizes, newColors) {
          setState(() {
            _activeFilters = newFilters;
            _filterCount = newFilters.length;
            minPrice = newMinPrice;
            maxPrice = newMaxPrice;
            minRating = newMinRating;
            categories = newCategories;
            sizes = newSizes;
            colors = newColors;
          });
          _performSearch();
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSort: _sortBy,
        onSortChanged: (sort) {
          setState(() {
            _sortBy = sort;
          });
          switch (sort) {
            case 'Price: Low to High':
              orderBy = 'price';
              orderDirection = 'ASC';
              break;
            case 'Price: High to Low':
              orderBy = 'price';
              orderDirection = 'DESC';
              break;
            case 'Customer Rating':
              orderBy = 'avg_rating';
              orderDirection = 'DESC';
              break;
            case 'Newest':
              orderBy = 'created';
              orderDirection = 'DESC';
              break;
            default:
              orderBy = 'title_en';
              orderDirection = 'ASC';
          }
          _performSearch();
        },
      ),
    );
  }

  void _onProductTap(
      BuildContext context, SearchEntity product, String wishListId) {
    Navigator .
    pushNamed(
      context,
      AppRoutes.productDetailScreen,
      arguments: {'productId': product.productId, 'wishListId': wishListId,'context':context},
    );
  }

  void _showProductContextMenu(SearchEntity product, Offset position,BuildContext ctx) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('Add to Wishlist'),
            ],
          ),
          onTap: () => _toggleWishlist(
              userWishList, product.productId, product.isWishlist, false,ctx),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('Share'),
            ],
          ),
          onTap: () {},
        ),
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('View Similar'),
            ],
          ),
          onTap: () {},
        ),
      ],
    );
  }

  // Map<String, dynamic> _mapSearchEntityToProduct(dynamic entity) {
  //   if (entity is Map<String, dynamic>) {
  //     return entity;
  //   }
  //
  //   return {
  //     "id": entity.productId,
  //     "name": entity.titleEn,
  //     "price": entity.price,
  //     "originalPrice": entity.price * (1 + entity.discountPercentage / 100),
  //     "discount": entity.discountPercentage.round(),
  //     "rating": entity.rating,
  //     "reviewCount": entity.reviewCount,
  //     "image": entity.images.isNotEmpty ? entity.images[0] : '',
  //     "isWishlisted": entity.isWishlist,
  //     "brand": "",
  //     "category": entity.categoryNameEn,
  //     "sizes": entity.sizes,
  //     "colors": entity.colorsEn,
  //     "inStock": entity.stock > 0,
  //   };
  // }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPageNavigation(PaginationModel pagination) {
    return NumberPagination(
      controlButtonSize: Size(4.h, 4.h),
      buttonRadius: 15,
      unSelectedNumberColor: AppTheme.backgroundDark,
      selectedNumberColor: AppTheme.backgroundLight,
      controlButtonColor: AppTheme.backgroundDark,
      selectedButtonColor: AppTheme.accentDark,
      onPageChanged: (int pageNumber) {
        setState(() {
          _goToPage(pageNumber);
        });
      },
      visiblePagesCount: 5,
      totalPages: _totalPages,
      currentPage: _currentPage,
      // enableInteraction: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _searchBloc,
      child: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() {
              _isLoadingMore = false;
            });
          } else if (state is SearchLoaded) {
            setState(() {
              _isLoadingMore = false;
              _totalPages = state.pagination.totalPages;
            });
          }
        },
        builder: (ctx, state) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Header with search and filter
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow
                              .withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Search bar with filter and sort buttons
                        Row(
                          children: [
                            Container(
                              height: 6.h,
                              width: 6.h,
                              decoration: BoxDecoration(
                                color: AppTheme
                                    .lightTheme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(3.w),
                                      child: CustomIconWidget(
                                        iconName: 'search',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 20,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 2.h,
                                    ),
                                  ),
                                  onSubmitted: (value) => _performSearch(),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            // Sort button
                            Container(
                              height: 6.h,
                              width: 6.h,
                              decoration: BoxDecoration(
                                color: AppTheme
                                    .lightTheme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: _showSortBottomSheet,
                                icon: CustomIconWidget(
                                  iconName: 'sort',
                                  color: AppTheme.lightTheme.colorScheme
                                      .onSecondaryContainer,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            // Filter button with badge
                            Stack(
                              children: [
                                Container(
                                  height: 6.h,
                                  width: 6.h,
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: _showFilterModal,
                                    icon: CustomIconWidget(
                                      iconName: 'tune',
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                _filterCount > 0
                                    ? Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(1.w),
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .lightTheme.colorScheme.error,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: 5.w,
                                            minHeight: 5.w,
                                          ),
                                          child: Text(
                                            _filterCount.toString(),
                                            style: AppTheme
                                                .lightTheme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),

                        // Tab bar
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),

                  // Active filters chips
                  _activeFilters.isNotEmpty
                      ? Container(
                          height: 6.h,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _activeFilters.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(width: 2.w),
                                  itemBuilder: (context, index) {
                                    return FilterChipWidget(
                                      label: _activeFilters[index],
                                      onRemove: () => _removeFilter(
                                          _activeFilters[index], index),
                                    );
                                  },
                                ),
                              ),
                              TextButton(
                                onPressed: _clearAllFilters,
                                child: Text(
                                  'Clear All',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),

                  // Products grid
                  Expanded(
                    child: _buildContent(state,ctx),
                  ),

                  // Page navigation controls
                  if (state is SearchLoaded && _totalPages > 1)
                    _buildPageNavigation(state.pagination),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(SearchState state,BuildContext ctx) {
    if (state is SearchLoading) {
      return _buildSkeletonGrid();
    } else if (state is SearchError) {
      return _buildErrorState(state.message);
    } else if (state is SearchLoaded) {
      return _buildProductGrid(state.products, state.pagination,ctx);
    } else if (state is SearchInitial) {
      return _buildEmptyState();
    } else {
      return const SizedBox();
    }
  }

  Widget _buildProductGrid(
      List<SearchEntity> products, PaginationModel pagination,BuildContext ctx) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          // Results count and pagination info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${pagination.totalItems} products found',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Products grid
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 4.w,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= products.length) {
                  return _buildLoadingIndicator();
                }

                final product = products[index];
                final mappedProduct = (product);

                return ProductCardWidget(
                  product: mappedProduct,
                  onTap: (p) => _onProductTap(ctx, p, userWishList),
                  onLongPress: (position) =>
                      _showProductContextMenu(product, position,ctx),
                  onWishlistTap: () => _toggleWishlist(userWishList,
                      product.productId, product.isWishlist, false,ctx),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: 20.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  height: 2.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.h),
                // Price skeleton
                Container(
                  height: 1.5.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No products found',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your filters or search terms',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Something went wrong',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
