import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:fluttermart/presentation/Auth/presentation/bloc/auth_bloc.dart';
import 'package:fluttermart/presentation/Auth/presentation/bloc/auth_event.dart';
import 'package:fluttermart/presentation/home/presentation/bloc/home_bloc.dart';
import 'package:fluttermart/presentation/product_detail_screen/presentation/bloc/product_detail_bloc.dart';
import 'package:sizer/sizer.dart';
import '../widgets/custom_error_widget.dart';
import 'core/app_export.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependencies

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(errorDetails: details);
  };

  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MultiBlocProvider(
        providers: [
          // Provide your AuthBloc to the entire app
          BlocProvider(create: (context) => di.sl<AuthBloc>()  ..add(
            AuthCheckEvent(),
          )),
          BlocProvider(
            create: (context) => di.sl<ProductDetailBloc>(),

          ),
          BlocProvider(
            create: (context) => di.sl<HomeBloc>(),
           )
          // Add other BLoCs here as needed
        ],
        child:MaterialApp(
          title: 'E-Commerce App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRoutes.onGenerateRoute, // ✅ use this
          initialRoute: AppRoutes.loginScreen,        // Start with login screen
        )

      );
    });
  }
}