import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/other_screen/account_detail/account_detail_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../db_models/profile_model.dart';
import '../../db_service/database_helper.dart';
import '../../utils/global.dart';
import '../../utils/views/custom_text_form_field.dart';
import 'bloc/edit_account_detail_bloc.dart';
import 'bloc/edit_account_detail_state.dart';

class EditAccountDetailScreen extends StatefulWidget {
  const EditAccountDetailScreen({super.key});

  @override
  State<EditAccountDetailScreen> createState() =>
      _EditAccountDetailScreenState();
}

class _EditAccountDetailScreenState extends State<EditAccountDetailScreen> {
  EditAccountDetailBloc editAccountDetailBloc = EditAccountDetailBloc();

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
  bool isLoading = true;

  ProfileModel? profileData;
  String actualBudget = "";
  String userEmail = '';
  String currentBalance = '';
  String currentIncome = '';
  int id = 0;

  bool validateEmail(String email) {
    RegExp emailRegex =
        RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> getProfileData() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      ProfileModel? fetchedProfileData =
          await databaseHelper.getProfileData(userEmail);
      setState(() {
        profileData = fetchedProfileData;
        id = profileData!.id!;
        firstNameController.text = profileData!.first_name!;
        lastNameController.text = profileData!.last_name!;
        emailController.text = profileData!.email!;
        dateOfBirth = profileData!.dob!;
        currentBalance = profileData!.current_balance!;
        currentIncome = profileData!.current_income!;
        actualBudget = profileData!.actual_budget!;
        selectedValue =
            profileData!.gender == "" ? 'Female' : profileData!.gender!;
        isLoading = false;
      }
      );
      getShortName(profileData!.first_name!, profileData!.last_name!);
    } catch (error) {
      print('Error fetching Profile Data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getShortName(String name, String name1) {
    String firstStr = name.split(" ").first;
    String secondStr = name1.split(" ").first;

    String firstChar = firstStr.substring(0, 1);
    String secondChar = secondStr.substring(0, 1);

    return shortName = firstChar + secondChar;
  }

  Future<void> updateProfileData() async {
    await databaseHelper.updateProfileData(
      ProfileModel(
          id: id,
          first_name: firstNameController.text,
          last_name: lastNameController.text,
          email: emailController.text,
          dob: dateOfBirth == null ? "Select DOB" : dateOfBirth!,
          gender: selectedValue,
          current_balance: currentBalance,
          current_income: currentIncome,
          actual_budget: actualBudget,
          full_name: "",
          profile_image: "",
          mobile_number: ""),
    );
    Helper.showToast("Profile update successful!");
    getProfileData();
  }

  @override
  void initState() {
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
        getProfileData();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    editAccountDetailBloc.context = context;
    return BlocConsumer<EditAccountDetailBloc, EditAccountDetailState>(
      bloc: editAccountDetailBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is EditAccountDetailInitial) {
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
                        child: Text("Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Helper.getTextColor(context),
                            )),
                      ),
                    ],
                  ),
                ),
                title: Text("Account details",
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
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
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
                              hintText: "Enter First Name",
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
                                  getShortName(firstNameController.text,
                                      lastNameController.text);
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
                              hintText: "Enter Last Name",
                              hintColor: Helper.getTextColor(context),
                              textStyle: const TextStyle(fontSize: 16),
                              borderRadius: BorderRadius.circular(10),
                              borderColor: Helper.getTextColor(context),
                              fillColor: Helper.getCardColor(context),
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
                                  getShortName(firstNameController.text,
                                      lastNameController.text);
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
                              hintText: "Enter Email",
                              hintColor: Helper.getTextColor(context),
                              textStyle: const TextStyle(fontSize: 16),
                              borderRadius: BorderRadius.circular(10),
                              borderColor: Helper.getTextColor(context),
                              fillColor: Helper.getCardColor(context),
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
                                  bool isValid =
                                      validateEmail(value.toString());
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
                                              foregroundColor: Colors
                                                  .blue, // button text color
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  String formattedDate =
                                      DateFormat("yMMMd").format(pickedDate);
                                  dateOfBirth = formattedDate;
                                  setState(() {});
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
                                    horizontal: 10, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_sharp,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    10.widthBox,
                                    Text(
                                      dateOfBirth == ""
                                          ? "Select DOB"
                                          : dateOfBirth!,
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
                                    border: Border.all(
                                        color: Helper.getTextColor(context)),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: DropdownButtonHideUnderline(
                                      child: DropdownButton2(
                                        dropdownElevation: 2,
                                        buttonDecoration: BoxDecoration(
                                            color:
                                                Helper.getCardColor(context)),
                                        dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color:
                                                Helper.getCardColor(context)),
                                        customButton: Container(
                                            color: Helper.getCardColor(context),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 10),
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
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Helper
                                                              .getTextColor(
                                                                  context))),
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Helper.getTextColor(
                                                      context),
                                                )
                                              ],
                                            )),
                                        items: dropdownItems
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(item,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Helper
                                                              .getTextColor(
                                                                  context))),
                                                ))
                                            .toList(),
                                        dropdownMaxHeight: 200,
                                        offset: const Offset(0, -1),
                                        value: selectedValue,
                                        onChanged: (value) {
                                          setState(() {
                                            var val = value as String;
                                            selectedValue = val;
                                          });
                                        },
                                        iconSize: 28,
                                        buttonPadding: EdgeInsets.zero,
                                        buttonHeight: 40,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )),
                                  ],
                                )),
                            (MediaQuery.of(context).size.height / 5).heightBox,
                            InkWell(
                              onTap: () {
                                updateProfileData();

                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AccountDetailScreen()));
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Helper.getCardColor(context),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            30.heightBox,
                          ],
                        ),
                      ),
              ));
        }
        return Container();
      },
    );
  }
}
