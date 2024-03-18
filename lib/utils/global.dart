import 'dart:ui';

abstract class ImageConstanst {

  static const String icGoogle = 'asset/images/ic_google.svg';
  static const String icFacebook = 'asset/images/ic_facebook.svg';
  static const String icApple = 'asset/images/ic_apple.svg';
  static const String icPhone = 'asset/images/img_phone.png';
  static const String icBanner = 'asset/images/ic_banner.svg';
  static const String icFlag = 'asset/images/ic_flag.png';

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

}