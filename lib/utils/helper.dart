import 'package:expense_manager/db_models/payment_method_model.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db_models/expense_category_model.dart';
import '../db_models/income_category.dart';
import '../db_models/expense_sub_category.dart';
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

  static Color getCategoriesItemColors(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().dividerColor;
  }

  static Future<void> addDefaultCategories() async {
    final databaseHelper = DatabaseHelper.instance;

    List<ExpenseCategory> spendingCategories = [];
    spendingCategories.add(
        ExpenseCategory(name: 'Dine out', color: Colors.blue, icons: 'ic_dine_out'));
    spendingCategories
        .add(ExpenseCategory(name: 'Commute', color: Colors.blue, icons: 'ic_commute'));
    spendingCategories.add(
        ExpenseCategory(name: 'Enjoyment', color: Colors.blue, icons: 'ic_enjoyment'));
    spendingCategories.add(
        ExpenseCategory(name: 'Child care', color: Colors.blue, icons: 'ic_child_care'));
    spendingCategories.add(
        ExpenseCategory(name: 'Shopping', color: Colors.blue, icons: 'ic_shopping'));
    spendingCategories.add(
        ExpenseCategory(name: 'Insurance', color: Colors.blue, icons: 'ic_insurance'));
    spendingCategories
        .add(ExpenseCategory(name: 'Health', color: Colors.blue, icons: 'ic_health'));
    spendingCategories.add(
        ExpenseCategory(name: 'Personal', color: Colors.blue, icons: 'ic_personal'));
    await databaseHelper.insertAllCategory(spendingCategories);

    List<ExpenseSubCategory> spendingSubCategories = [];
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'BreakFast', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Lunch', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Dinner', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Snacks', categoryId: 1, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Fuel', categoryId: 2, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Movies', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Concert', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Party', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Sports', categoryId: 3, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'School Fees',
        categoryId: 4,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Tuition', categoryId: 4, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Vaccination',
        categoryId: 4,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Clothing', categoryId: 5, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Grocery', categoryId: 5, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Electronics',
        categoryId: 5,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Auto', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Health', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Home', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Life', categoryId: 6, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Dental', categoryId: 7, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Eye Care', categoryId: 7, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Nutrition', categoryId: 7, priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Personal Care',
        categoryId: 8,
        priority: AppConstanst.priorityHigh));
    spendingSubCategories.add(ExpenseSubCategory(
        name: 'Gift', categoryId: 8, priority: AppConstanst.priorityHigh));
    await databaseHelper.insertAllSpendingSubCategory(spendingSubCategories);

    List<IncomeCategory> incomeCategories = [];
    incomeCategories.add(IncomeCategory(
        name: 'Salary',
        color: Colors.blue,
        path: 'ic_salary',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Bonus',
        color: Colors.blue,
        path: 'ic_bonus',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Part-Time Work',
        color: Colors.blue,
        path: 'ic_part_time_work',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Pensions',
        color: Colors.blue,
        path: 'ic_pension',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Equities',
        color: Colors.blue,
        path: 'ic_equity',
        parentId: 1,
        status: 1));
    incomeCategories.add(IncomeCategory(
        name: 'Coupons',
        color: Colors.blue,
        path: 'ic_coupon',
        parentId: 1,
        status: 1));
    await databaseHelper.insertIncomeAllCategory(incomeCategories);

    List<PaymentMethod> paymentMethods = [];
    paymentMethods.add( PaymentMethod(name: 'Cash',status: 1,icon: 'ic_cash'));
    paymentMethods.add( PaymentMethod(name: 'Online',status: 1,icon: 'ic_online_payment'));
    paymentMethods.add( PaymentMethod(name: 'Card',status: 1,icon: 'ic_card'));
    await databaseHelper.insertAllPaymentMethods(paymentMethods);
  }

  static Color getCardColor(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().cardColor;
  }
static Color getChartColor(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return themeNotifier.getTheme().disabledColor;
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

  static void showLoading(BuildContext context) {


    AlertDialog alert=AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  static void hideLoading(context) {
    //Get.back();
    Navigator.pop(context);
  }

  static String getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  static bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  static String getTransactionDay(String date){
    var transactionDay = "";
    DateFormat format = DateFormat("dd/MM/yyyy");
    DateTime parsedDate = format.parse(date);
    if(isToday(parsedDate)){
      transactionDay = "TODAY";
    }else if(isYesterday(parsedDate)){
      transactionDay = "YESTERDAY";
    }else{
      transactionDay = Helper.getWeekdayName(parsedDate.weekday);
    }
    return transactionDay;
  }

  static bool isAfterDay(String date){
    DateFormat format = DateFormat("dd/MM/yyyy");
    DateTime parsedDate = format.parse(date);
    return parsedDate.isAfter(parsedDate);
  }
}
