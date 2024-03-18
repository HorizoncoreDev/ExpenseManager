import 'package:expense_manager/navigation/routes_key.dart';
import 'package:flutter/material.dart';

import '../budget/budget_screen.dart';
import '../intro_screen/intro_screen.dart';
import '../sign_in/sign_in_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {

      case Routes.intro:
        return MaterialPageRoute(builder: (context) => const IntroScreen());

      case Routes.signIn:
        return MaterialPageRoute(builder: (context) => const SignInScreen());

      /*case Routes.budget:
        return MaterialPageRoute(builder: (context) => const BudgetScreen());*/

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Error"),
          ),
          body: const Center(
            child: Text("Page not found!"),
          ),
        );
      },
    );
  }
}
