import 'package:ai_stock_analyzer/Screens/auth/login_screen.dart';
import 'package:ai_stock_analyzer/Screens/home_page.dart';
import 'package:flutter/material.dart';

class Page_Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageRouteBuilder(pageBuilder: (_, __, ___) => HomePage());
      case '/login':
        return PageRouteBuilder(pageBuilder: (_, __, ___) => LoginPage());
      default:
        return MaterialPageRoute(
            builder: (context) => const Text("Encountered Some Error !"));
    }
  }
}
