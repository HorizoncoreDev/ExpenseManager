import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../db_models/accounts_model.dart';
import '../../db_models/profile_model.dart';
import '../../db_service/database_helper.dart';
import '../../utils/global.dart';
import '../../utils/views/custom_text_form_field.dart';

class EditAccountDetailScreen extends StatefulWidget {
  const EditAccountDetailScreen({super.key});

  @override
  State<EditAccountDetailScreen> createState() =>
      _EditAccountDetailScreenState();
}

class _EditAccountDetailScreenState extends State<EditAccountDetailScreen> {
  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? dateOfBirth;

  String selectedValue = 'Female';
  List<String> dropdownItems = ['Male', 'Female'];

  bool emailIsValid = false;
  String shortName = "";

  ProfileModel? profileData;
  String actualBudget = "";
  String userEmail = '';
  String currentBalance = '';
  String currentIncome = '';
  String key = '';
  String userCode = '';
  String fcmToken = '';

  String accountKey = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leadingWidth: 80,
          automaticallyImplyLeading: false,
          backgroundColor: Helper.getBackgroundColor(context),
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(LocaleKeys.cancel.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Helper.getTextColor(context),
                      )),
                ),
              ],
            ),
          ),
          title: Text(LocaleKeys.accountDetails.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Helper.getTextColor(context),
              )),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          width: double.infinity,
          height: double.infinity,
          color: Helper.getBackgroundColor(context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                15.heightBox,
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueGrey,
                      ),
                      child: Text(
                        shortName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                20.heightBox,
                CustomBoxTextFormField(
                  controller: firstNameController,
                  keyboardType: TextInputType.text,
                  hintText: LocaleKeys.enterName.tr,
                  padding: 15,
                  decoration: const InputDecoration(counterText: ""),
                  hintColor: Helper.getTextColor(context),
                  textStyle: const TextStyle(fontSize: 16),
                  borderRadius: BorderRadius.circular(10),
                  borderColor: Helper.getTextColor(context),
                  fillColor: Helper.getCardColor(context),
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.blue,
                  ),
                  suffixIcon: firstNameController.text.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              firstNameController.clear();
                            });
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.grey,
                          ))
                      : 0.widthBox,
                  onChanged: (value) {
                    setState(() {
                      getShortName(
                          firstNameController.text, lastNameController.text);
                    });
                  },
                  validator: (value) {
                    return null;
                  },
                ),
                20.heightBox,
                CustomBoxTextFormField(
                  controller: lastNameController,
                  keyboardType: TextInputType.text,
                  hintText: LocaleKeys.enterLastName.tr,
                  hintColor: Helper.getTextColor(context),
                  textStyle: const TextStyle(fontSize: 16),
                  borderRadius: BorderRadius.circular(10),
                  borderColor: Helper.getTextColor(context),
                  fillColor: Helper.getCardColor(context),
                  padding: 15,
                  decoration: const InputDecoration(counterText: ""),
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.blue,
                  ),
                  suffixIcon: lastNameController.text.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              lastNameController.clear();
                            });
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.grey,
                          ))
                      : 0.widthBox,
                  onChanged: (value) {
                    setState(() {
                      getShortName(
                          firstNameController.text, lastNameController.text);
                    });
                  },
                  validator: (value) {
                    return null;
                  },
                ),
                20.heightBox,
                CustomBoxTextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.text,
                  hintText: LocaleKeys.enterEmail.tr,
                  hintColor: Helper.getTextColor(context),
                  textStyle: const TextStyle(fontSize: 16),
                  borderRadius: BorderRadius.circular(10),
                  borderColor: Helper.getTextColor(context),
                  fillColor: Helper.getCardColor(context),
                  padding: 15,
                  decoration: const InputDecoration(counterText: ""),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.blue,
                  ),
                  suffixIcon: emailIsValid
                      ? const Icon(
                          Icons.verified,
                          color: Colors.green,
                        )
                      : 0.widthBox,
                  onChanged: (value) {
                    setState(() {
                      bool isValid = validateEmail(value.toString());
                      emailIsValid = isValid;
                    });
                  },
                  validator: (value) {
                    return null;
                  },
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
                        initialDate: DateTime(2003),
                        firstDate: DateTime(1980),
                        lastDate: DateTime(2005));
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat("yMMMd").format(pickedDate);
                      setState(() {
                        dateOfBirth = formattedDate;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Helper.getCardColor(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Helper.getTextColor(context),
                        )),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_sharp,
                          color: Colors.blue,
                          size: 18,
                        ),
                        10.widthBox,
                        Text(
                          dateOfBirth ?? "Select DOB",
                          style: TextStyle(
                            fontSize: 14,
                            color: Helper.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                20.heightBox,
                Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: Helper.getCardColor(context),
                        border: Border.all(color: Helper.getTextColor(context)),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(
                            child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            customButton: Container(
                                color: Helper.getCardColor(context),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                margin: const EdgeInsets.all(2.5),
                                child: Row(
                                  children: [
                                    Icon(
                                      selectedValue == "Male"
                                          ? Icons.male
                                          : Icons.female,
                                      color: Colors.blue,
                                    ),
                                    8.widthBox,
                                    Expanded(
                                      child: Text(selectedValue,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Helper.getTextColor(
                                                  context))),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Helper.getTextColor(context),
                                    )
                                  ],
                                )),
                            items: dropdownItems
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Helper.getTextColor(
                                                  context))),
                                    ))
                                .toList(),
                            dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                    color: Helper.getCardColor(context),
                                    borderRadius: BorderRadius.circular(8))),
                            value: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                var val = value as String;
                                selectedValue = val;
                              });
                            },
                            isExpanded: true,
                          ),
                        )),
                      ],
                    )),
                (MediaQuery.of(context).size.height / 5).heightBox,
                InkWell(
                  onTap: () {
                    updateProfileData();
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Helper.getCardColor(context),
                        borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: Text(
                      LocaleKeys.update.tr,
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 14),
                    ),
                  ),
                ),
                30.heightBox,
              ],
            ),
          ),
        ));
  }

  Future<void> getProfileData() async {
    try {
      ProfileModel? fetchedProfileData =
          await databaseHelper.getProfileData(userEmail);

      if (fetchedProfileData != null) {
        setState(() {
          profileData = fetchedProfileData;
          key = profileData!.key!;
          userCode = profileData!.user_code!;
          firstNameController.text = profileData!.first_name!;
          lastNameController.text = profileData!.last_name!;
          emailController.text = profileData!.email!;
          dateOfBirth =
              profileData!.dob!.isEmpty ? "Select DOB" : profileData!.dob!;
          currentBalance = profileData!.current_balance!;
          currentIncome = profileData!.current_income!;
          actualBudget = profileData!.actual_budget!;
          fcmToken = profileData!.fcm_token!;
          selectedValue =
              profileData!.gender == "" ? 'Female' : profileData!.gender!;
        });
        getShortName(profileData!.first_name!, profileData!.last_name!);
      } else {
        setState(() {});
      }
    } catch (error) {
      print('Error fetching Profile Data: $error');
      setState(() {});
    }
  }

  String getShortName(String name, String name1) {
    String firstStr = name.split(" ").first;
    String secondStr = name1.split(" ").first;

    String firstChar = firstStr.substring(0, 1);
    String secondChar = secondStr.substring(0, 1);

    return shortName = firstChar + secondChar;
  }

  @override
  void initState() {
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currentUserKey)
        .then((value) {
      if (value != null) {
        key = value;
        MySharedPreferences.instance
            .getStringValuesSF(SharedPreferencesKeys.userEmail)
            .then((value) {
          if (value != null) {
            userEmail = value;
            MySharedPreferences.instance
                .getStringValuesSF(SharedPreferencesKeys.currentAccountKey)
                .then((value) {
              if (value != null) {
                accountKey = value;
              }
              getProfileData();
            });
          }
        });
      }
    });
    super.initState();
  }

  Future<void> updateProfileData() async {
    ProfileModel profileModel = ProfileModel(
        key: key,
        first_name: firstNameController.text,
        last_name: lastNameController.text,
        email: emailController.text,
        dob: dateOfBirth == null ? "Select DOB" : dateOfBirth!,
        gender: selectedValue,
        current_balance: currentBalance,
        current_income: currentIncome,
        actual_budget: actualBudget,
        user_code: userCode,
        full_name: "${firstNameController.text} ${lastNameController.text}",
        profile_image: "",
        mobile_number: "",
        fcm_token: fcmToken,
        lang_code: Get.locale!.languageCode,
        currency_code: AppConstanst.currencyCode,
        created_at: DateTime.now().toString(),
        currency_symbol: AppConstanst.currencySymbol);
    await databaseHelper.updateProfileData(profileModel);

    AccountsModel accountsModel = AccountsModel(
        key: accountKey,
        balance: currentBalance,
        income: currentIncome,
        budget: actualBudget,
        account_name: "${firstNameController.text} ${lastNameController.text}",
        description: "",
        account_status: 1,
        owner_user_key: key,
        created_at: DateTime.now().toString(),
        balance_date: DateTime.now().toString(),
        updated_at: DateTime.now().toString());
    await databaseHelper.updateAccountData(accountsModel);

    MySharedPreferences.instance.addStringToSF(SharedPreferencesKeys.userName,
        "${firstNameController.text} ${lastNameController.text}");

    Helper.showToast("Profile update successful!");
    getProfileData();
  }

  bool validateEmail(String email) {
    RegExp emailRegex =
        RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$");
    return emailRegex.hasMatch(email);
  }
}
