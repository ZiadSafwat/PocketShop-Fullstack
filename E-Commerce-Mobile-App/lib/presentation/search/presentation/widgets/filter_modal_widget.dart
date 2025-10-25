import 'package:flutter/material.dart';
import 'package:fluttermart/presentation/home/presentation/bloc/home_bloc.dart';
import 'package:fluttermart/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../../../widgets/custom_icon_widget.dart';
import '../../../home/domain/entities/home_entity.dart';

class FilterModalWidget extends StatefulWidget {
  final List<String> activeFilters;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final List<String> selectedCategories; // Now holds category IDs
  final List<String> selectedSizes;
  final List<String> selectedColors;
  final Function(List<String>, double, double, double, List<String>, List<String>, List<String>) onFiltersChanged;

  const FilterModalWidget({
    super.key,
    required this.activeFilters,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.selectedCategories,
    required this.selectedSizes,
    required this.selectedColors,
    required this.onFiltersChanged,
  });

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late List<String> _selectedCategoryIds;
  late List<String> _selectedSizes;
  late List<String> _selectedColors;
  late RangeValues _priceRange;
  late double _minRating;

  // These will be populated from the home bloc
  late List<CategoryEntity> _categoryOptions;
  late List<String> _sizeOptions;
  late List<String> _colorOptions;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds =  (widget.selectedCategories);
    _selectedSizes = (widget.selectedSizes);
    _selectedColors = (widget.selectedColors);
    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
    _minRating = widget.minRating;

    // Initialize with empty lists, will be updated when we get data from cubit
    _categoryOptions = [];
    _sizeOptions = [];
    _colorOptions = [];
  }

  void _toggleFilter(String type, String filter) {
    setState(() {
      switch (type) {
        case 'Size':
          if (_selectedSizes.contains(filter)) {
            _selectedSizes.remove(filter);
          } else {
            _selectedSizes.add(filter);
          }
          break;
        case 'Color':
          if (_selectedColors.contains(filter)) {
            _selectedColors.remove(filter);
          } else {
            _selectedColors.add(filter);
          }
          break;
      }
    });
  }

  void _toggleCategoryFilter(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedSizes.clear();
      _selectedColors.clear();
      _priceRange = const RangeValues(0, 100000);
      _minRating = 0;
    });
  }

  void _applyFilters() {
    final List<String> allFilters = [];

    // Map selected category IDs to their titles for the UI chips
    final allCategories = _flattenCategories(
        (BlocProvider.of<HomeBloc>(context).state as HomeLoaded).homeData.categories);
    final selectedCategoryTitles = _selectedCategoryIds.map((id) {
      final category = allCategories.firstWhereOrNull((cat) => cat.id == id);
      return category?.titleEn ?? '';
    }).where((title) => title.isNotEmpty).toList();

    // Add categories
    allFilters.addAll(selectedCategoryTitles.map((c) => 'Category: $c'));

    // Add sizes
    allFilters.addAll(_selectedSizes.map((s) => 'Size: $s'));

    // Add colors
    allFilters.addAll(_selectedColors.map((c) => 'Color: $c'));

    // Add price range filter
    if (_priceRange.start > 0 || _priceRange.end < 100000) {
      allFilters.add('Price: \$${_priceRange.start.round()}-\$${_priceRange.end.round()}');
    }

    // Add rating filter
    if (_minRating > 0) {
      allFilters.add('Rating: ${_minRating.toStringAsFixed(1)}+ stars');
    }

    widget.onFiltersChanged(
      allFilters,
      _priceRange.start,
      _priceRange.end,
      _minRating,
      _selectedCategoryIds, // Now passing the IDs
      _selectedSizes,
      _selectedColors,
    );
    Navigator.pop(context);
  }

  // Helper function to flatten the nested categories
  List<CategoryEntity> _flattenCategories(List<CategoryEntity> input) {
    final List<CategoryEntity> result = [];
    for (final category in input) {
      result.add(category);
      if (category.children.isNotEmpty) {
        result.addAll(_flattenCategories(category.children));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Update filter options when home data is available
        if (state is HomeLoaded) {
          final homeData = state.homeData;
          _categoryOptions = _flattenCategories(homeData.categories);
          _sizeOptions = homeData.availableFilters.sizes ?? [];
          _colorOptions = homeData.availableFilters.colors ?? [];

        }

        return Container(
          height: 90.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 2.h),
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Text(
                      'Filters',
                      style: AppTheme.lightTheme.textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text(
                        'Clear All',
                        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price range
                      _buildPriceRangeSection(),

                      SizedBox(height: 3.h),

                      // Rating filter
                      _buildRatingSection(),

                      SizedBox(height: 3.h),

                      // Category filters
                      if (_categoryOptions.isNotEmpty)
                        _buildCategoryFilterSection('Category', _categoryOptions),

                      if (_categoryOptions.isNotEmpty) SizedBox(height: 3.h),

                      // Size filters
                      if (_sizeOptions.isNotEmpty)
                        _buildGeneralFilterSection('Size', _sizeOptions, _selectedSizes),

                      if (_sizeOptions.isNotEmpty) SizedBox(height: 3.h),

                      // Color filters
                      if (_colorOptions.isNotEmpty)
                        _buildGeneralFilterSection('Color', _colorOptions, _selectedColors),
                    ],
                  ),
                ),
              ),

              // Apply button
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withOpacity(0.2),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text('Apply Filters (${_selectedCategoryIds.length + _selectedSizes.length + _selectedColors.length + (_priceRange.start > 0 || _priceRange.end < 100000 ? 1 : 0) + (_minRating > 0 ? 1 : 0)})'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 100000,
          divisions: 50,
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_priceRange.start.round()}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            Text(
              '\$${_priceRange.end.round()}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: _minRating > 0
              ? '${_minRating.toStringAsFixed(1)} stars'
              : 'Any rating',
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
        ),
        Row(
          children: [
            ...List.generate(5, (index) {
              return CustomIconWidget(
                iconName: index < _minRating.floor() ? 'star' : 'star_border',
                color: index < _minRating.floor()
                    ? Colors.amber
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              );
            }),
            SizedBox(width: 2.w),
            Text(
              _minRating > 0
                  ? '${_minRating.toStringAsFixed(1)} & up'
                  : 'Any rating',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilterSection(String title, List<CategoryEntity> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = _selectedCategoryIds.contains(option.id);
            return FilterChip(
              label: Text(option.titleEn),
              selected: isSelected,
              onSelected: (selected) => _toggleCategoryFilter(option.id),
              selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
              checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
              labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.onPrimaryContainer
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGeneralFilterSection(String title, List<String> options, List<String> selectedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selectedList.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) => _toggleFilter(title, option),
              selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
              checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
              labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.onPrimaryContainer
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}