import 'dart:io';

import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'budget/budget_screen.dart';
import 'intro_screen/intro_screen.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: 'AIzaSyCjDfTo2L6aTfWJbVPXigIFyvtzChQLcRs',
      appId: '1:233058085418:android:bc906b3cbcd1b16a893153',
      messagingSenderId: '233058085418',
      projectId: 'expense-management-27995'))
      : await Firebase.initializeApp();
  // DatabaseHelper helper = DatabaseHelper();
 /* final databaseHelper = DatabaseHelper.instance;
  await databaseHelper.database;
  // await emDatabase.checkTableExistence();

  await databaseHelper.insertUserData(UserModel(
    id: 1,
    username: 'vinit',
    password: 'vinit@123',
    email: 'vinit@gmail.com',
    full_name: 'Vinit Soni',
    current_balance: '5,00,000',
    profile_image: '',
    mobile_number: '6541239874',
    created_at: '2023-11-28 12:00:00',
    last_updated: '2023-11-28 12:00:00',
  ));

  await databaseHelper.insertPaymentMethod(PaymentMethod(
    id: 1,
    name: 'Cash',
    status: 1,
  ));
  await databaseHelper.insertPaymentMethod(PaymentMethod(
    id: 2,
    name: 'Credit Card',
    status: 1,
  ));
  await databaseHelper.insertPaymentMethod(PaymentMethod(
    id: 3,
    name: 'Debit Card',
    status: 1,
  ));


  await databaseHelper.insertExpenseCategory(ExpenseCategory(
    id: 1,
    name: 'Family',
    parentId: 1,
    path: '',
    status: 1,
  ));
  await databaseHelper.insertExpenseCategory(ExpenseCategory(
    id: 2,
    name: 'Food',
    parentId: 2,
    path: '',
    status: 1,
  ));
  await databaseHelper.insertExpenseCategory(ExpenseCategory(
    id: 3,
    name: 'Tax',
    parentId: 3,
    path: '',
    status: 3,
  ));

  await databaseHelper.insertIncomeCategory(IncomeCategory(
    id: 1,
    name: 'Salary',
    parentId: 1,
    path: '',
    status: 1,
  ));
  await databaseHelper.insertIncomeCategory(IncomeCategory(
    id: 2,
    name: 'Personal Savings',
    parentId: 1,
    path: '',
    status: 1,
  ));
  await databaseHelper.insertIncomeCategory(IncomeCategory(
    id: 3,
    name: 'Rents and royalties',
    parentId: 1,
    path: '',
    status: 1,
  ));


  await databaseHelper.insertTransactionData(TransactionModel(
    id: 1,
    member_id: 1,
    amount: 5000,
    expense_cat_id: 0,
    income_cat_id: 1,
    sub_expense_cat_id: 0,
    sub_income_cat_id: 0,
    payer_id: 101,
    payee_id: 201,
    payment_method_id: 1,
    status: 1,
    check_no: '',
    description: '',
    currency_id: 1,
    receipt_image: '',
    created_at: '2023-11-28 12:00:00',
    last_updated: '2023-11-28 12:00:00',
  ));*/

  return runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    /*SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blue, // Change this color to the desired color
   //   statusBarIconBrightness: Brightness.light, // For dark/light icons on status bar
    ));*/

    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeNotifier.getTheme(),
      /*ThemeData(
      // brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          background: Colors.black87,
          //primary: Colors.black87,
        ),
       // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
       // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        useMaterial3: true,
      ),*/
      home: user == null ? const IntroScreen() : const BudgetScreen(),
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
