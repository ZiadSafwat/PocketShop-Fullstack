import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_icon_widget.dart';


class ProductOptionsWidget extends StatelessWidget {
  final List<String> sizes;
  final List<String> colors;
  final String selectedSize;
  final String selectedColor;
  final int quantity;
  final Function(String) onSizeChanged;
  final Function(String) onColorChanged;
  final Function(int) onQuantityChanged;

  const ProductOptionsWidget({
    super.key,
    required this.sizes,
    required this.colors,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
    required this.onSizeChanged,
    required this.onColorChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Size Selection
            if(sizes.isNotEmpty)
       ... [      Text(
            'Size',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          SizedBox(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sizes.length,
              itemBuilder: (context, index) {
                final size = sizes[index];
                final isSelected = size == selectedSize;

                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: GestureDetector(
                    onTap: () => onSizeChanged(size),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 3.h),],
          if(colors.isNotEmpty)
            ...[
          // Color Selection
          Text(
            'Color',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),


            SizedBox(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = color == selectedColor;

                return Container(
                  margin: EdgeInsets.only(right: 3.w),
                  child: GestureDetector(
                    onTap: () => onColorChanged(color),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              color: _getColorFromName(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline,
                                width: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            color,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),],
          SizedBox(height: 3.h),

          // Quantity Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: quantity > 1
                          ? () => onQuantityChanged(quantity - 1)
                          : null,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'remove',
                          color: quantity > 1
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                      child: Text(
                        quantity.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onQuantityChanged(quantity + 1),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
      case 'أبيض':
        return Colors.white;
      case 'black':
      case 'أسود':
        return Colors.black;
      case 'navy blue':
      case 'كحلي':
        return Colors.blue.shade800;
      case 'gray':
      case 'رمادي':
        return Colors.grey;
      case 'beige':
      case 'بيج':
        return Colors.brown.shade50;
      case 'olive green':
      case 'أخضر زيتي':
        return Colors.green.shade700;
      case 'burgundy':
      case 'عنابي':
        return Colors.red.shade900;
      case 'emerald green':
      case 'أخضر زمردي':
        return Colors.green.shade600;
      case 'mustard yellow':
      case 'أصفر خردلي':
        return Colors.amber;
      case 'coral':
      case 'مرجاني':
        return Colors.deepOrange.shade400;
      case 'dusty pink':
      case 'وردي فاتح':
        return Colors.pink.shade200;
      case 'lavender':
      case 'بنفسجي فاتح':
        return Colors.purple.shade200;
      case 'camel':
      case 'جملي':
        return Colors.brown.shade300;
      case 'indigo':
      case 'نيلي':
        return Colors.indigo;
      case 'teal':
      case 'تركواز':
        return Colors.teal;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
