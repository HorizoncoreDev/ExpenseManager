import 'dart:io';

import 'package:expense_manager/dashboard/dashboard.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'budget/budget_screen.dart';
import 'intro_screen/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isBudgetAdded = false;
  bool isSkippedUser = false;

  MySharedPreferences.instance
      .getBoolValuesSF(SharedPreferencesKeys.isBudgetAdded)
      .then((value) {
    if (value != null) {
      isBudgetAdded = value;
    }
  });
  MySharedPreferences.instance
      .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
      .then((value) {
    if (value != null) {
      isBudgetAdded = value;
    }
  });
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyCjDfTo2L6aTfWJbVPXigIFyvtzChQLcRs',
              appId: '1:233058085418:android:bc906b3cbcd1b16a893153',
              messagingSenderId: '233058085418',
              projectId: 'expense-management-27995'))
      : await Firebase.initializeApp();

  return runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: MyApp(
      isBudgetAdded: isBudgetAdded,
      isSkippedUser: isSkippedUser,
    ),
  ));
}

class MyApp extends StatelessWidget {
  bool isBudgetAdded;
  bool isSkippedUser;

  MyApp({super.key, required this.isBudgetAdded, required this.isSkippedUser});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: themeNotifier.getTheme(),
        home: isBudgetAdded
            ? const DashBoard()
            : isSkippedUser
                ? const BudgetScreen()
                : user == null
                    ? const IntroScreen()
                    : const BudgetScreen()

        /*user == null
          ? const IntroScreen()
          : isBudgetAdded
              ? const DashBoard()
              : const BudgetScreen(),*/
        );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(),
    );
  }
}
