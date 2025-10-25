import 'package:flutter/material.dart';
import 'package:fluttermart/core/app_export.dart';
import 'package:fluttermart/presentation/home/domain/entities/home_entity.dart';
import 'package:sizer/sizer.dart';


class CategoryGridWidget extends StatelessWidget {
  const CategoryGridWidget({super.key, required this.categories});

  final List<CategoryEntity> categories;

  // Recursive function to flatten all categories and subcategories
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

  void _onCategoryTap(BuildContext context, CategoryEntity category) {

    Navigator.pushNamed(
      context,
      AppRoutes.productBrowseScreen,
      arguments: {'withCategories': [category.id]},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get flattened list of all categories
    final flattenedCategories = _flattenCategories(categories);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
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
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.85,
            ),
            itemCount: flattenedCategories.length,
            itemBuilder: (context, index) {
              final category = flattenedCategories[index];

              return GestureDetector(
                onTap: () => _onCategoryTap(context, category),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.dividerColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.shadow
                            .withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomImageWidget(
                            imageUrl: category.image,
                            width: 15.w,
                            height: 15.w,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        category.titleAr,
                        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${category.totalItemsNumber} items',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//this code to priview category as it is (tree or nodes of categories)
//class CategoryGridWidget extends StatefulWidget {
//   const CategoryGridWidget({super.key, required this.categories});
//
//   final List<CategoryEntity> categories;
//
//   @override
//   State<CategoryGridWidget> createState() => _CategoryGridWidgetState();
// }
//
// class _CategoryGridWidgetState extends State<CategoryGridWidget> {
//   final Map<String, bool> _expandedState = {};
//
//   void _onCategoryTap(CategoryEntity category) {
//     if (category.hasChildren) {
//       setState(() {
//         _expandedState[category.id] = !(_expandedState[category.id] ?? false);
//       });
//     } else {
//       Navigator.pushNamed(context, '/product-browse-screen');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Shop by Category',
//                 style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/product-browse-screen');
//                 },
//                 child: Text(
//                   'View All',
//                   style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
//                     color: AppTheme.lightTheme.colorScheme.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 2.h),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: widget.categories.length,
//             itemBuilder: (context, index) {
//               final category = widget.categories[index];
//               final isExpanded = _expandedState[category.id] ?? false;
//
//               return Container(
//                 margin: EdgeInsets.only(bottom: 2.h),
//                 decoration: BoxDecoration(
//                   color: AppTheme.lightTheme.colorScheme.surface,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppTheme.lightTheme.dividerColor,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppTheme.lightTheme.colorScheme.shadow
//                           .withOpacity(0.05),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     // Parent Category Tile
//                     ListTile(
//                       onTap: () => _onCategoryTap(category),
//                       leading: Container(
//                         width: 12.w,
//                         height: 12.w,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Center(
//                           child: CustomImageWidget(
//                             imageUrl: category.image,
//                             width: 15.w,
//                             height: 15.w,
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         category.titleAr,
//                         style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       subtitle: Text(
//                         '${category.totalItemsNumber} items',
//                         style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                           color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                       trailing: category.hasChildren
//                           ? Icon(
//                         isExpanded
//                             ? Icons.expand_less
//                             : Icons.expand_more,
//                         color: AppTheme.lightTheme.colorScheme.primary,
//                       )
//                           : null,
//                     ),
//
//                     // Subcategories Expansion
//                     if (category.hasChildren && isExpanded)
//                       Padding(
//                         padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 2.h),
//                         child: GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3,
//                             crossAxisSpacing: 3.w,
//                             mainAxisSpacing: 2.h,
//                             childAspectRatio: 0.85,
//                           ),
//                           itemCount: category.children.length,
//                           itemBuilder: (context, childIndex) {
//                             final subCategory = category.children[childIndex];
//
//                             return GestureDetector(
//                               onTap: () => Navigator.pushNamed(
//                                   context, '/product-browse-screen'),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.lightTheme.colorScheme.surface,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: AppTheme.lightTheme.dividerColor,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       width: 12.w,
//                                       height: 12.w,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Center(
//                                         child: CustomImageWidget(
//                                           imageUrl: subCategory.image,
//                                           width: 15.w,
//                                           height: 15.w,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(height: 1.5.h),
//                                     Text(
//                                       subCategory.titleAr,
//                                       style: AppTheme.lightTheme.textTheme.labelLarge
//                                           ?.copyWith(
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     SizedBox(height: 0.5.h),
//                                     Text(
//                                       '${subCategory.totalItemsNumber} items',
//                                       style: AppTheme.lightTheme.textTheme.bodySmall
//                                           ?.copyWith(
//                                         color: AppTheme.lightTheme.colorScheme
//                                             .onSurfaceVariant,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
