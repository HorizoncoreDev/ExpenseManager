import 'package:expense_manager/dashboard/dashboard.dart';
import 'package:expense_manager/db_models/language_category_model.dart';
import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageBottomSheetContent extends StatefulWidget {
  @override
  _LanguageBottomSheetContentState createState() =>
      _LanguageBottomSheetContentState();
}

class _LanguageBottomSheetContentState
    extends State<LanguageBottomSheetContent> {
  List<LanguageCategory> languageTypes = [];
  final databaseHelper = DatabaseHelper.instance;
  String? language = "";
  String? langCode = "";
  LanguageCategory? selectedLanguage;
  ProfileModel? profileModel;
  String userEmail = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    langCode = Get.locale!.languageCode;

    getLanguageTypes();
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
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.selectLanguage.tr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Helper.getTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Helper.getTextColor(context),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: languageTypes.length,
              itemBuilder: (BuildContext context, int index) {
                final LanguageCategory languageCategory = languageTypes[index];
                print('object...list..$langCode');
                return ListTile(
                  title: Text(languageCategory.name.toString()),
                  onTap: () {
                    setState(() {
                      language = languageCategory.name;
                      langCode = languageCategory.code;
                      print('object.....$langCode');
                    });
                  },
                  trailing: langCode == languageCategory.code
                      ? const Icon(Icons.check)
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                Locale getLocale;
                Navigator.of(context).pop();
                MySharedPreferences.instance.addStringToSF(
                    SharedPreferencesKeys.languageCode, langCode);
                if (langCode == "en") {
                  getLocale = const Locale('en', 'US');
                  Get.updateLocale(getLocale);
                  print("local en is $getLocale");
                } else if (langCode == "hi") {
                  getLocale = const Locale('hi', 'IN');
                  Get.updateLocale(getLocale);
                  print("local hi is $getLocale");
                } else if (langCode == "gu") {
                  getLocale = const Locale('gu', 'GJ');
                  Get.updateLocale(getLocale);
                  print("local gu is $getLocale");
                }
                MySharedPreferences.instance
                    .getStringValuesSF(SharedPreferencesKeys.userEmail)
                    .then((value) async {
                  if (value != null) {
                    userEmail = value;
                    await DatabaseHelper.instance
                        .getProfileData(userEmail)
                        .then((profileData) async {
                      profileData!.lang_code = langCode;
                      await DatabaseHelper.instance
                          .updateProfileData(profileData);
                    });
                    await databaseHelper.updateProfileData(profileModel!);
                  }
                });

                Get.deleteAll();
                Get.offAll(DashBoard());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Text(
                  LocaleKeys.update.tr,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
