import 'package:flutter/material.dart';

import 'package:qawam/features/bottom_nav/presentation/screens/bottom_nav_screen.dart';
import 'package:qawam/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:qawam/features/login/presentation/screens/login_screen.dart';
import 'package:qawam/features/settings/presentation/screens/settings_screen.dart';
import 'package:qawam/features/profile/presentation/screens/profile_screen.dart';
import 'package:qawam/features/spalsh/presentation/screens/spalsh_screen.dart';
import 'unknown_route.dart';

class AppRouter {
  ///[navigatorKey] is the global NavigatorState key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SpalshScreen(),
          settings: settings,
        );
      case LoginScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case BottomNavScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScreen(),
          settings: settings,
        );
      case SettingsScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case ProfileScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case ExpensesScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const ExpensesScreen(),
          settings: settings,
        );
      default:
        return unknownRoute;
    }
  }

  static BuildContext get currentContext => navigatorKey.currentState!.context;

  static Route get unknownRoute =>
      MaterialPageRoute(builder: (context) => const UnknownRoute());

  //To go back or close snackBars, dialogs, bottomSheets, or anything you would normally close with Navigator.pop(context);
  static void pop(dynamic data) {
    navigatorKey.currentState?.pop(data);
  }

  //Navigate to new screen with name
  static Future<Object?>? to(String route, {Object? data}) async {
    return await navigatorKey.currentState?.pushNamed(route, arguments: data);
  }

  //To go to the next screen and no option to go back to the previous screen
  static Future<Object?>? toReplacement(String route, {Object? data}) async {
    return await navigatorKey.currentState?.pushReplacementNamed(
      route,
      arguments: data,
    );
  }

  //To go to the next screen and cancel all previous routes
  static Future<Object?>? toAndRemoveUntil(String route, {Object? data}) async {
    return await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (route) => false,
      arguments: data,
    );
  }
}
