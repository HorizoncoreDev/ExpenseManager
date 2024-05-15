import 'dart:ui';

import 'package:expense_manager/utils/languages/en_US.dart';
import 'package:expense_manager/utils/languages/gu_GJ.dart';
import 'package:expense_manager/utils/languages/hi_IN.dart';
import 'package:get/get.dart';

class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static final fallBackLocale = Get.locale;

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US' : enUS, 'gu_GJ' : guGJ, 'hi_IN' : hiIN
  };

}