import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../db_models/category_model.dart';
import '../db_models/income_category.dart';
import '../db_models/spending_sub_category.dart';
import '../db_service/database_helper.dart';

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

  static Future<void> addDefaultCategories() async {
    final databaseHelper = DatabaseHelper.instance;

    List<Category> spendingCategories = [];
    spendingCategories.add(
        Category(name: 'Dine out', color: Colors.blue, icons: 'ic_google'));
    spendingCategories
        .add(Category(name: 'Commute', color: Colors.blue, icons: 'ic_google'));
    spendingCategories.add(
        Category(name: 'Enjoyment', color: Colors.blue, icons: 'ic_google'));
    spendingCategories.add(
        Category(name: 'Child care', color: Colors.blue, icons: 'ic_google'));
    spendingCategories.add(
        Category(name: 'Shopping', color: Colors.blue, icons: 'ic_google'));
    spendingCategories.add(
        Category(name: 'Insurance', color: Colors.blue, icons: 'ic_google'));
    spendingCategories
        .add(Category(name: 'Health', color: Colors.blue, icons: 'ic_google'));
    spendingCategories.add(
        Category(name: 'Personal', color: Colors.blue, icons: 'ic_google'));
    await databaseHelper.insertAllCategory(spendingCategories);

    List<SpendingSubCategory> spendingSubCategories = [];
    spendingSubCategories.add(SpendingSubCategory(
        name: 'BreakFast', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Lunch', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Dinner', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Snacks', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Fuel', categoryId: 2, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Movies', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Concert', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Party', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Sports', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'School Fees',
        categoryId: 4,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Tuition', categoryId: 4, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Vaccination',
        categoryId: 4,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Clothing', categoryId: 5, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Grocery', categoryId: 5, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Electronics',
        categoryId: 5,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Auto', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Health', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Home', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Life', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Dental', categoryId: 7, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Eye Care', categoryId: 7, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Nutrition', categoryId: 7, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Personal Care',
        categoryId: 8,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(SpendingSubCategory(
        name: 'Gift', categoryId: 8, priority: AppConstanst.priorityHigh));
    await databaseHelper.insertAllSpendingSubCategory(spendingSubCategories);

    List<IncomeCategory> incomeCategories = [];
    incomeCategories.add(IncomeCategory(
        name: 'Salary',
        color: Colors.blue,
        path: 'ic_google',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Bonus',
        color: Colors.blue,
        path: 'ic_google',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Part-Time Work',
        color: Colors.blue,
        path: 'ic_google',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Pensions',
        color: Colors.blue,
        path: 'ic_google',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Equities',
        color: Colors.blue,
        path: 'ic_google',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Coupons',
        color: Colors.blue,
        path: 'ic_google',
        parentId: 1,
        status: 1));
    await databaseHelper.insertIncomeAllCategory(incomeCategories);
  }

  static Color getCardColor(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().cardColor;
  }

  static BottomNavigationBarThemeData getBottomNavigationColor(
      BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().bottomNavigationBarTheme;
  }

  static Color getMiddleBottomNavBarItem(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().canvasColor;
  }
}
