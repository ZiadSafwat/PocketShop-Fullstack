import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttermart/core/databases/api/end_points.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final Widget? errorWidget;
  final Widget? placeholder;
  final Color? placeholderColor;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.low,
    this.errorWidget,
    this.placeholder,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveImageUrl = imageUrl != null && imageUrl!.isNotEmpty
        ? EndPoints.baserUrl + imageUrl!
        : '${EndPoints.baserUrl}files/d307x3zqff91y9v/mmf3off8f3r9frx/box_2071537_640_iA7kzWD6ej.png?token=';

    return CachedNetworkImage(
      imageUrl: effectiveImageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
      errorWidget: (context, url, error) =>
      errorWidget ??
          Image.asset(
            "assets/images/no-image.jpg",
            fit: fit,
            width: width,
            height: height,
          ),
      placeholder: (context, url) => placeholder ??
          Container(
            width: width,
            height: height,
            color: placeholderColor ?? Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
    );
  }
}