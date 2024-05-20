import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/db_models/language_category_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/sign_in/sign_in_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/global.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<LanguageCategory> languageTypes = [];
  final databaseHelper = DatabaseHelper.instance;
  LanguageCategory? language;
  bool languageDropdownOpen = false;

  final List<String> texts1 = [
    'Make a\nplan for\nrevenue',
    'Monitor\nyour\nlibrary',
    'Manage\nprinciple',
    'Add\nspending\nand\nincome',
  ];

  final List<String> texts2 = [
    'Reports\nand charts',
    'Manage\nyour\ncategories',
    'Themes\nand\noffline\nmode',
    'Invite\nyour\nfriends',
  ];

  var colors = [
    Colors.red,
    Colors.blue,
    Colors.cyan,
    Colors.green,
  ];

  var colorsList = [
    Colors.grey,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      color: Helper.getBackgroundColor(context),
      child: SingleChildScrollView(
        child: Column(
          children: [
            130.heightBox,
            SizedBox(
              width: double.infinity,
              height: 110,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: texts1.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    height: 110,
                    padding: const EdgeInsets.all(3),
                    alignment: Alignment.bottomLeft,
                    color: colors[index],
                    child: Text(
                      texts1[index],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return 10.widthBox;
                },
              ),
            ),
            10.heightBox,
            SizedBox(
              width: double.infinity,
              height: 110,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: texts2.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    height: 110,
                    padding: const EdgeInsets.all(3),
                    alignment: Alignment.bottomLeft,
                    color: colorsList[index],
                    child: Text(
                      texts2[index],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return 10.widthBox;
                },
              ),
            ),
            80.heightBox,
            Text(
              LocaleKeys.smartExpense.tr,
              style: TextStyle(
                  color: Helper.getTextColor(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            10.heightBox,
            Text(
              LocaleKeys.smartSpender.tr,
              style: TextStyle(
                color: Helper.getTextColor(context),
                fontSize: 16,
              ),
            ),
            50.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                decoration: BoxDecoration(
                  color: Helper.getCardColor(context),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    15.widthBox,
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<LanguageCategory>(
                          dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius: BorderRadius.circular(8))),
                          items: languageTypes
                              .map<DropdownMenuItem<LanguageCategory>>(
                                  (LanguageCategory value) {
                            return DropdownMenuItem<LanguageCategory>(
                              value: value,
                              child: Text(value.name!),
                            );
                          }).toList(),
                          hint: Text(LocaleKeys.selectLanguage.tr),
                          value: language,
                          onChanged: (value) {
                            setState(() {
                              var val = value;
                              language = val;
                              MySharedPreferences.instance.addStringToSF(
                                  SharedPreferencesKeys.languageCode,
                                  language!.code);
                              Locale getLocale;
                              if (language!.code == "en") {
                                getLocale = const Locale('en', 'US');
                                Get.updateLocale(getLocale);
                                print("local en is $getLocale");
                              } else if (language!.code == "hi") {
                                getLocale = const Locale('hi', 'IN');
                                Get.updateLocale(getLocale);
                                print("local hi is $getLocale");
                              } else if (language!.code == "gu") {
                                getLocale = const Locale('gu', 'GJ');
                                Get.updateLocale(getLocale);
                                print("local gu is $getLocale");
                              }
                              Get.deleteAll();
                            });
                          },
                          onMenuStateChange: (isOpen) {
                            setState(() {
                              languageDropdownOpen = isOpen;
                            });
                          },
                          isExpanded: true,
                          iconStyleData: IconStyleData(
                              icon: Icon(
                            !languageDropdownOpen
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.white,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            20.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: InkWell(
                onTap: () {
                  if (language != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    Helper.showToast(LocaleKeys.plSelectLang.tr);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text(
                    LocaleKeys.start.tr,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
            10.heightBox
          ],
        ),
      ),
    ));
  }

  Future<void> getLanguageTypes() async {
    try {
      List<LanguageCategory> languageTypesList =
          await databaseHelper.languageMethods();
      setState(() {
        languageTypes = languageTypesList;
      });
    } catch (e) {
      Helper.showToast(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isCurrencyAndLanguageAdded)
        .then((value) {
      if (value != null) {
        if (!value) {
          Helper.addCurrencyAndLanguages().then((value) =>
              MySharedPreferences.instance.addBoolToSF(
                  SharedPreferencesKeys.isCurrencyAndLanguageAdded, true));
          getLanguageTypes();
        }
      } else {
        Helper.addCurrencyAndLanguages().then((value) =>
            MySharedPreferences.instance.addBoolToSF(
                SharedPreferencesKeys.isCurrencyAndLanguageAdded, true));
        getLanguageTypes();
      }
    });
  }
}
