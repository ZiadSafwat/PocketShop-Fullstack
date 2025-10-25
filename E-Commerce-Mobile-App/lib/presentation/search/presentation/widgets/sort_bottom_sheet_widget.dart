import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_icon_widget.dart';


class SortBottomSheetWidget extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortChanged;

  const SortBottomSheetWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sortOptions = [
      {
        'title': 'Relevance',
        'subtitle': 'Best match for your search',
        'icon': 'trending_up',
      },
      {
        'title': 'Price: Low to High',
        'subtitle': 'Lowest price first',
        'icon': 'arrow_upward',
      },
      {
        'title': 'Price: High to Low',
        'subtitle': 'Highest price first',
        'icon': 'arrow_downward',
      },
      {
        'title': 'Customer Rating',
        'subtitle': 'Highest rated first',
        'icon': 'star',
      },
      {
        'title': 'Newest',
        'subtitle': 'Latest arrivals first',
        'icon': 'schedule',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        
            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Text(
                    'Sort by',
                    style: AppTheme.lightTheme.textTheme.headlineSmall,
                  ),
                  const Spacer(),
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
        
            // Sort options
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortOptions.length,
              separatorBuilder: (context, index) => Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final option = sortOptions[index];
                final isSelected = currentSort == option['title'];
        
                return ListTile(
                  leading: CustomIconWidget(
                    iconName: option['icon'] as String,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  title: Text(
                    option['title'] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    option['subtitle'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    onSortChanged(option['title'] as String);
                    Navigator.pop(context);
                  },
                );
              },
            ),
        
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
