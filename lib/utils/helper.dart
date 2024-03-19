import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


class Helper {
  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static Color getBackgroundColor(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().backgroundColor;
  }

  static Color getTextColor(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().hintColor;
  }

  static Color getCardColor(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().cardColor;
  }

  static BottomNavigationBarThemeData getBottomNavigationColor(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().bottomNavigationBarTheme;
  }

  static Color getMiddleBottomNavBarItem(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().canvasColor;
  }


}