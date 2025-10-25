import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/Auth/presentation/bloc/auth_bloc.dart';
import '../../presentation/Auth/presentation/bloc/auth_state.dart';
import '../../presentation/Auth/presentation/screens/login_screen.dart';
import '../../presentation/home/presentation/screens/home_screen.dart';
import '../../routes/app_routes.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.initial,
            (route) => false,
          );
// Handle navigation based on state changes
//         if (state is AuthLogout) {
//           Navigator.of(context).pushNamedAndRemoveUntil(
//             AppRoutes.loginScreen,
//             (route) => false,
//           );
//         } else if (state is AuthSuccess) {
//           Navigator.of(context).pushNamedAndRemoveUntil(
//             AppRoutes.homeScreen,
//             (route) => false,
//           );
//         }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthSuccess) {
          return HomeScreen();
        } else if (state is AuthLogout) {
          return LoginScreen();
        } else  {
          return LoginScreen();
        }
      },
    );
  }
}
