import 'dart:ui';

abstract class ImageConstanst {
  static const String icGoogle = 'asset/images/ic_google.svg';
  static const String icFacebook = 'asset/images/ic_facebook.svg';
  static const String icApple = 'asset/images/ic_apple.svg';
  static const String icPhone = 'asset/images/img_phone.png';
  static const String icBanner = 'asset/images/ic_banner.svg';
  static const String icFlag = 'asset/images/ic_flag.png';
  static const String icCSV = 'asset/images/ic_csv.png';
  static const String isDrive = 'asset/images/ic_drive.png';
  static const String isDb = 'asset/images/ic_db.png';
}

abstract class AppConstanst {
  static const int spendingTransaction = 1;
  static const int incomeTransaction = 2;
  static const int cashPaymentType = 1;
  static const int rupeesCurrency = 1;
  static int signInClicked = 0;
  static int selectedTabIndex = 0;

  static const int mainCategory = 0;
  static const int subCategory = 1;

  static const int pendingRequest = 1;
  static const int acceptedRequest = 2;
  static const int rejectedRequest = 3;
  static const int removedRequest = 4;

  static  bool notificationClicked = false;

  static const String priorityHigh = "High";
  static const String priorityMedium = "Medium";
  static const String priorityLow = "Low";
  static const String spendingTransactionName = "Spending";
  static const String incomeTransactionName = "Income";
}

abstract class AppColors {
  static const primaryColor = Color(0xFF0DA6E7);

  static Color textFieldBorderColor = const Color(0xFFCBD5E1);
  static Color textFieldFillBorderColor = const Color(0xffF1F5F9);

  static Color backgroundColor = const Color(0xff161417);
  static Color blueColor = const Color(0xff0a8ee1);
  static Color lightBlackColor = const Color(0xff2a292e);
}

abstract class SharedPreferencesKeys {
  static const isLogin = "isLogin";
  static const isCategoriesAdded = "isCategoriesAdded";
  static const isCurrencyAndLanguageAdded = "isCurrencyAndLanguageAdded";
  static const isBudgetAdded = "isBudgetAdded";
  static const userEmail = "userEmail";
  static const currentUserEmail = "currentUserEmail";
  static const userFcmToken = "userFcmToken";
  static const userName = "userName";
  static const currentUserName = "currentUserName";
  static const isSkippedUser = "skippedUser";
  static const skippedUserCurrentBalance = "skippedUserCurrentBalance";
  static const skippedUserCurrentIncome = "skippedUserCurrentIncome";
  static const skippedUserActualBudget = "skippedUserActualBudget";
  static const isMasterPasswordGenerated = "isMasterPasswordGenerated";
}
