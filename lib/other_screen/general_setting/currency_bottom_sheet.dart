import 'package:expense_manager/dashboard/dashboard.dart';
import 'package:expense_manager/db_models/currency_category_model.dart';
import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrencyBottomSheet extends StatefulWidget {
  final Function(String) setData; // Callback function to set data in the screen

  CurrencyBottomSheet({super.key, required this.setData});

  @override
  State<CurrencyBottomSheet> createState() => _CurrencyBottomSheetState();
}

class _CurrencyBottomSheetState extends State<CurrencyBottomSheet> {
  List<CurrencyCategory> currencyTypes = [];
  int selectedCurrency = -1;
  int selectedLang = -1;
  String cCode = "";
  String cSymbol = "";
  ProfileModel? profileModel;
  final databaseHelper = DatabaseHelper.instance;
  String userEmail = "";

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
                  LocaleKeys.selectCurrency.tr,
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
              itemCount: currencyTypes.length,
              itemBuilder: (BuildContext context, int index) {
                final CurrencyCategory currencyCategory = currencyTypes[index];
                return ListTile(
                  title: Text(currencyCategory.currencyCode.toString()),
                  onTap: () {
                    setState(() {
                      cCode = currencyCategory.currencyCode!;
                      cSymbol = currencyCategory.symbol!;
                    });
                  },
                  trailing: cCode == currencyCategory.currencyCode
                      ? const Icon(Icons.check)
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                widget.setData(cCode);
                Navigator.of(context).pop();
                setState(() {
                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.currencySymbol, cSymbol);
                  MySharedPreferences.instance
                      .addStringToSF(SharedPreferencesKeys.currencyCode, cCode);
                });
                MySharedPreferences.instance
                    .getStringValuesSF(SharedPreferencesKeys.userEmail)
                    .then((value) async {
                  if (value != null) {
                    userEmail = value;
                    await DatabaseHelper.instance
                        .getProfileData(userEmail)
                        .then((profileData) async {
                      profileData!.currency_code = cCode;
                      profileData.currency_symbol = cSymbol;
                      await DatabaseHelper.instance
                          .updateProfileData(profileData);
                    });
                    await databaseHelper.updateProfileData(profileModel!);
                  }
                });
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
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getCurrencyTypes() async {
    try {
      List<CurrencyCategory> currencyTypeList =
      await databaseHelper.currencyMethods();
      setState(() {
        currencyTypes = currencyTypeList;
        if (cCode.isEmpty && currencyTypes.isNotEmpty) {
          cCode = currencyTypes[0].currencyCode!;
          cSymbol = currencyTypes[0].symbol!;
        }
      });
    } catch (e) {
      Helper.showToast(e.toString());
    }
  }

 /* Future<void> getCurrencyTypes() async {
    try {
      List<CurrencyCategory> currencyTypeList =
      await databaseHelper.currencyMethods();
      setState(() {
        currencyTypes = currencyTypeList;
      });
    } catch (e) {
      Helper.showToast(e.toString());
    }
  }*/

  @override
  void initState() {
    super.initState();
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currencyCode)
        .then((value) {
      if (value != null) {
        cCode = value;
      }
    });
    getCurrencyTypes();
  }

}
