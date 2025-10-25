import 'package:flutter/material.dart';
import 'package:fluttermart/core/widgets/auth_checker.dart';
import 'package:fluttermart/presentation/search/presentation/search_screen.dart';
import '../presentation/Auth/presentation/screens/login_screen.dart';
import '../presentation/home/presentation/screens/home_screen.dart';
import '../presentation/product_detail_screen/presentation/product_detail_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/shopping_cart_screen/shopping_cart_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String userProfileScreen = '/user-profile-screen';
  static const String productBrowseScreen = '/product-browse-screen';
  static const String productDetailScreen = '/product-detail-screen';
  static const String homeScreen = '/home-screen';
  static const String shoppingCartScreen = '/shopping-cart-screen';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => AuthChecker());
      case loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case userProfileScreen:
        return MaterialPageRoute(builder: (_) => UserProfileScreen());
      case productBrowseScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => ProductBrowseScreen(withCategories:  args==null?[]:args!['withCategories'],));
      case productDetailScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductScreen(productId: args['productId'],wishListId:args['wishListId'] ,blocContext:args['context'] ),
        );
      case homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case shoppingCartScreen:
        return MaterialPageRoute(builder: (_) => ShoppingCartScreen());
    }
    return null;
  }
}
