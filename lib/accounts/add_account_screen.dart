import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/db_models/currency_category_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../dashboard/dashboard.dart';
import '../utils/global.dart';
import '../utils/views/custom_text_form_field.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final FocusNode _focus = FocusNode();
  TextEditingController budgetController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController balanceController = TextEditingController();

  String userEmail = '';
  bool isSkippedUser = false;
  List<CurrencyCategory> currencyTypes = [];
  final databaseHelper = DatabaseHelper.instance;
  CurrencyCategory? currency;
  String currencyCode = "";
  String currencySymbol = "";
  bool currencyDropdownOpen = false;
  DateTime selectedDate = DateTime.now();

  String formattedDate() {
    return DateFormat('dd/MM/yyyy').format(selectedDate);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddAccountScreen()));
          },
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Text(
              LocaleKeys.addAccount.tr,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Helper.getBackgroundColor(context),
            titleSpacing: 10,
            title: Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Helper.getTextColor(context),
                    )),
                Text(LocaleKeys.addAccount.tr,
                    style: TextStyle(
                      fontSize: 22,
                      color: Helper.getTextColor(context),
                    )),
              ],
            ),
            actions: [
        /*      InkWell(
                onTap: () async {
                  if (budgetController.text.isEmpty) {
                    Helper.showToast(LocaleKeys.enterBudgetText.tr);
                  } else {
                    if (!isSkippedUser) {
                      await DatabaseHelper.instance
                          .getProfileData(userEmail)
                          .then((profileData) async {
                        profileData!.current_balance =
                            budgetController.text.toString();
                        profileData.actual_budget =
                            budgetController.text.toString();
                        profileData.currency_code =
                        currencyCode.isEmpty ? "INR" : currencyCode;
                        profileData.currency_symbol =
                        currencySymbol.isEmpty ? "\u20B9" : currencySymbol;
                        await DatabaseHelper.instance
                            .updateProfileData(profileData);

                        MySharedPreferences.instance.addBoolToSF(
                            SharedPreferencesKeys.isBudgetAdded, true);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DashBoard()),
                                (Route<dynamic> route) => false);
                      });
                    } else {
                      MySharedPreferences.instance.addStringToSF(
                          SharedPreferencesKeys.skippedUserCurrentBalance,
                          budgetController.text.toString());
                      MySharedPreferences.instance.addStringToSF(
                          SharedPreferencesKeys.skippedUserCurrentIncome, "0");
                      MySharedPreferences.instance.addStringToSF(
                          SharedPreferencesKeys.skippedUserActualBudget,
                          budgetController.text.toString());
                      MySharedPreferences.instance.addBoolToSF(
                          SharedPreferencesKeys.isBudgetAdded, true);

                      MySharedPreferences.instance.addStringToSF(
                          SharedPreferencesKeys.currencyCode,
                          currencyCode.isEmpty ? "INR" : currencyCode);
                      MySharedPreferences.instance.addStringToSF(
                          SharedPreferencesKeys.currencySymbol,
                          currencySymbol.isEmpty ? "\u20B9" : currencySymbol);

                      MySharedPreferences.instance.addBoolToSF(
                          SharedPreferencesKeys.isBudgetAdded, true);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashBoard()),
                              (Route<dynamic> route) => false);
                    }
                  }
                  //budgetBloc.add(BudgetDoneEvent(budgetController.text));
                },
                child: Text(
                  "Done",
                  style: TextStyle(
                      fontSize: 14, color: Helper.getTextColor(context)),
                ),
              ),*/
              10.widthBox,
            ],

          ),
          body: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            color: Helper.getBackgroundColor(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  20.heightBox,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomBoxTextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      hintText: LocaleKeys.enterName.tr,
                      padding: 15,
                      borderColor: Helper.getCardColor(context),
                      hintColor: Helper.getTextColor(context),
                      textStyle: const TextStyle(fontSize: 16),
                      borderRadius: BorderRadius.circular(6),
                      fillColor: Helper.getCardColor(context),
                      prefixIcon: const Icon(
                        Icons.person_2_outlined,
                        color: Colors.blue,
                      ),
                      suffixIcon: nameController.text.isNotEmpty
                          ? InkWell(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              nameController.clear();
                            });
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.grey,
                          ))
                          : 0.widthBox,
                      onChanged: (value) {
                        setState(() {
                         /* getShortName(firstNameController.text,
                              lastNameController.text);*/
                        });
                      },
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                  20.heightBox,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomBoxTextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.text,
                      hintText: LocaleKeys.enterDescription.tr,
                      padding: 15,
                      borderColor: Helper.getCardColor(context),
                      hintColor: Helper.getTextColor(context),
                      textStyle: const TextStyle(fontSize: 16),
                      borderRadius: BorderRadius.circular(6),
                      fillColor: Helper.getCardColor(context),
                      prefixIcon: const Icon(
                        Icons.description,
                        color: Colors.blue,
                      ),
                      suffixIcon: descriptionController.text.isNotEmpty
                          ? InkWell(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              descriptionController.clear();
                            });
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.grey,
                          ))
                          : 0.widthBox,
                      onChanged: (value) {
                        setState(() {
                          /* getShortName(firstNameController.text,
                              lastNameController.text);*/
                        });
                      },
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                  20.heightBox,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Expanded(
                          child: CustomBoxTextFormField(
                              controller: budgetController,
                              onChanged: (val) {},
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5)),
                              keyboardType: TextInputType.number,
                              hintText: LocaleKeys.enterBudgetText.tr,
                              fillColor: Helper.getCardColor(context),
                              hintColor: Helper.getTextColor(context),
                              borderColor: Colors.transparent,
                              textStyle: TextStyle(
                                  color: Helper.getTextColor(context)),
                              padding: 15,
                              horizontalPadding: 5,
                              //focusNode: _focus,
                              validator: (value) {
                                return null;
                              })),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 5),
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              border: Border(
                                left: BorderSide(
                                  color: Helper.getCardColor(context),
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<CurrencyCategory>(
                                dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                        color: Helper.getCardColor(context),
                                        borderRadius:
                                        BorderRadius.circular(8))),
                                items: currencyTypes
                                    .map<DropdownMenuItem<CurrencyCategory>>(
                                        (CurrencyCategory value) {
                                      return DropdownMenuItem<CurrencyCategory>(
                                        value: value,
                                        child: Text(value.symbol!),
                                      );
                                    }).toList(),
                                hint: const Text("₹"),
                                value: currency,
                                onChanged: (value) {
                                  setState(() {
                                    currency = value;
                                    currencyCode = currency!.currencyCode!;
                                    currencySymbol = currency!.symbol!;
                                    MySharedPreferences.instance.addStringToSF(
                                        SharedPreferencesKeys.currencySymbol,
                                        currencySymbol);
                                    MySharedPreferences.instance.addStringToSF(
                                        SharedPreferencesKeys.currencyCode,
                                        currencyCode);
                                    print(
                                        "currency is ---- ${currency!.symbol}");
                                  });
                                },
                                onMenuStateChange: (isOpen) {
                                  setState(() {
                                    currencyDropdownOpen = isOpen;
                                  });
                                },
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    !currencyDropdownOpen
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                  ),
                                )),
                          )),
                    ]),
                  ),
                  20.heightBox,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomBoxTextFormField(
                      controller: balanceController,
                      keyboardType: TextInputType.text,
                      hintText: "Enter balance",
                      padding: 15,
                      borderColor: Helper.getCardColor(context),
                      hintColor: Helper.getTextColor(context),
                      textStyle: const TextStyle(fontSize: 16),
                      borderRadius: BorderRadius.circular(6),
                      fillColor: Helper.getCardColor(context),
                      prefixIcon: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.blue,
                      ),
                      suffixIcon: balanceController.text.isNotEmpty
                          ? InkWell(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              balanceController.clear();
                            });
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.grey,
                          ))
                          : 0.widthBox,
                      onChanged: (value) {
                        setState(() {
                          /* getShortName(firstNameController.text,
                              lastNameController.text);*/
                        });
                      },
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                  20.heightBox,
                  InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.blue,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                    Colors.blue, // button text color
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now());
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      } else if (pickedDate != null &&
                          pickedDate == DateTime.now()) {
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10 ),
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.date_range,
                              color: Colors.blue,
                              size: 18,
                            ),
                            8.widthBox,
                            Text(
                              formattedDate(),
                              style: TextStyle(
                                  color: Helper.getTextColor(context)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    budgetController.dispose();
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
  }

  Future<void> getCurrencyTypes() async {
    try {
      List<CurrencyCategory> currencyTypeList =
      await databaseHelper.currencyMethods();
      setState(() {
        currencyTypes = currencyTypeList;
      });
    } catch (e) {
      Helper.showToast(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
        getCurrencyTypes();
      }
    });
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
        getCurrencyTypes();
      }
    });
  }

  void _onFocusChange() {
    setState(() {});
  }
}
