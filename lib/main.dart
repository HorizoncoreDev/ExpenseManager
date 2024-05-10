import 'dart:io';

import 'package:expense_manager/dashboard/dashboard.dart';
import 'package:expense_manager/other_screen/family_account/family_account_screen.dart';
import 'package:expense_manager/sign_in/sign_in_screen.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:expense_manager/utils/push_notification_service.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'budget/budget_screen.dart';
import 'intro_screen/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isBudgetAdded = false;
  bool isSkippedUser = false;
  bool isLogin = false;

  MySharedPreferences.instance
      .getBoolValuesSF(SharedPreferencesKeys.isLogin)
      .then((value) {
    if (value != null) {
      isLogin = value;
    }
  });
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
      isSkippedUser = value;
    }
  });
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyCjDfTo2L6aTfWJbVPXigIFyvtzChQLcRs',
              appId: '1:233058085418:android:bc906b3cbcd1b16a893153',
              messagingSenderId: '233058085418',
              storageBucket: 'expense-management-27995.appspot.com',
              projectId: 'expense-management-27995'))
      : await Firebase.initializeApp();

   FirebaseDatabase.instance.setPersistenceEnabled(true);

  final FirebaseMessaging fcm = FirebaseMessaging.instance;

  await fcm.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );


  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload){});

  InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS,);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse){
        AppConstanst.notificationClicked = true;
        Get.to(()=>const FamilyAccountScreen());
      });

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Also handle any interaction when the app is in the background via a
  // Stream listener
  // FirebaseMessaging.onMessageOpenedApp.listen(_handleClick);
  // FirebaseMessaging.onMessage.listen(_handleMessageNew);
  FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    AppConstanst.notificationClicked = true;
    Get.to(()=>const FamilyAccountScreen());
  });

  MySharedPreferences.instance
      .getStringValuesSF(SharedPreferencesKeys.userFcmToken)
      .then((value) async {
    if (value == null || value.isEmpty) {
      await fcm.getToken().then((token) {
        MySharedPreferences.instance
            .addStringToSF(SharedPreferencesKeys.userFcmToken, token);
      });
    }
  });

  return runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: MyApp(
      isBudgetAdded: isBudgetAdded,
      isSkippedUser: isSkippedUser,
      isLogin: isLogin,
    ),
  ));
}


class MyApp extends StatefulWidget {

  bool isBudgetAdded;
  bool isSkippedUser;
  bool isLogin;

  MyApp(
      {super.key,
        required this.isBudgetAdded,
        required this.isSkippedUser,
        required this.isLogin});

  @override
  State<MyApp> createState() => _MyAppState(isBudgetAdded: this.isBudgetAdded,isSkippedUser: this.isSkippedUser,isLogin: this.isLogin);
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class _MyAppState extends State<MyApp> {

  bool isBudgetAdded;
  bool isSkippedUser;
  bool isLogin;

  _MyAppState(
      {
        required this.isBudgetAdded,
        required this.isSkippedUser,
        required this.isLogin});

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  //when application is in foreground
  void _handleMessage(RemoteMessage message) {
    AppConstanst.notificationClicked = true;
    Get.to(()=>const FamilyAccountScreen());
  }

  void _handleMessageNew(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      try {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
              ),
            ));
      } catch (e) {
        print(e);
      }
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
  }



  /// Function: listen for upcoming notification
  /// @return void
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
       _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.onMessage.listen(_handleMessageNew);

  }


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    // _notificationService.initialize();

    User? user = FirebaseAuth.instance.currentUser;

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: themeNotifier.getTheme(),
        home: AppConstanst.notificationClicked?
        const FamilyAccountScreen():isBudgetAdded
            ? isLogin
            ? const DashBoard()
            : isSkippedUser
            ? const DashBoard()
            : const SignInScreen()
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





