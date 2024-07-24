import 'package:expense_manager/budget/budget_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../db_models/profile_model.dart';
import '../../db_service/database_helper.dart';
import '../../sign_in/sign_in_screen.dart';
import '../../utils/global.dart';
import '../edit_account_detail/edit_account_detail_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({super.key});
  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;
  MySharedPreferences? mySharedPreferences;
  String? dateOfBirth;
  String dob = "";

  String selectedValue = 'Female';
  List<String> dropdownItems = ['Male', 'Female'];

  bool emailIsValid = false;
  String shortName = "";
  String fullName = "";
  String email = "";
  String userCode = "";
  bool isLoading = true;

  ProfileModel? profileData;

  String userEmail = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Helper.getTextColor(context),
              size: 18,
            )),
        backgroundColor: Helper.getBackgroundColor(context),
        titleSpacing: 0.0,
        title: Text(LocaleKeys.accountDetails.tr,
            style:
                TextStyle(fontSize: 20, color: Helper.getTextColor(context))),
        elevation: 0.0,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditAccountDetailScreen()),
              );
            },
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Helper.getCardColor(context)),
                child: Icon(
                  Icons.edit,
                  color: Helper.getTextColor(context),
                )),
          ),
          10.widthBox
        ],
      ),
      body: Container(
        color: Helper.getBackgroundColor(context),
        height: double.infinity,
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.heightBox,
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: Helper.getCardColor(context),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    10.widthBox,
                    Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Helper.getTextColor(context)),
                        ),
                        child: Container(
                            height: 50,
                            width: 50,
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white70),
                            child: Center(
                                child: Icon(
                              Icons.person,
                              color: Helper.getTextColor(context),
                              size: 35,
                            )))),
                    20.widthBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullName ?? "",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text(email ?? "",
                              style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              20.heightBox,
              Text(
                LocaleKeys.account.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Helper.getTextColor(context),
                    fontWeight: FontWeight.bold),
              ),
              5.heightBox,
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: Helper.getCardColor(context),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade800),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.blue,
                            ),
                          ),
                          15.widthBox,
                          Expanded(
                            child: Text(
                              LocaleKeys.accountLinked.tr,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Helper.getTextColor(context)),
                            ),
                          ),
                          SvgPicture.asset(
                            ImageConstanst.icGoogle,
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 0.2,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade800),
                            child: SvgPicture.asset(
                              'asset/images/ic_user_code.svg',
                              color: Colors.blue,
                              width: 25,
                            ),
                          ),
                          15.widthBox,
                          Expanded(
                            child: Wrap(
                              children: [
                                Text(
                                  LocaleKeys.userCode.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Helper.getTextColor(context)),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 5,
                            children: [
                              Text(
                                userCode,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.blue),
                              ),
                              IconButton(
                                  onPressed: () {
                                    Helper.copyText(context, userCode);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  style: const ButtonStyle(
                                    tapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, // the '2023' part
                                  ),
                                  icon: const Icon(
                                    Icons.copy_outlined,
                                    color: Colors.blue,
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 0.2,
                      color: Colors.grey,
                    ),
                    /* Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade800),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.blue,
                                  ),
                                ),
                                15.widthBox,
                                Expanded(
                                  child: Text(
                                    "User code",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Helper.getTextColor(context)),
                                  ),
                                ),
                                const Text(
                                  "EZR64Q",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 17),
                                ),
                                5.widthBox,
                                const Icon(
                                  Icons.copy_rounded,
                                  color: Colors.blue,
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 0.2,
                            color: Colors.grey,
                          ),*/
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: InkWell(
                        onTap: () async {
                          await _logOutDialog(context);
                          /*Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => SignInScreen()));*/
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade800),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.blue,
                              ),
                            ),
                            15.widthBox,
                            Expanded(
                              child: Text(
                                LocaleKeys.logout.tr,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Helper.getTextColor(context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              20.heightBox,
              Text(
                LocaleKeys.userData.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Helper.getTextColor(context),
                    fontWeight: FontWeight.bold),
              ),
              5.heightBox,
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: Helper.getCardColor(context),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: InkWell(
                        onTap: () {
                          _clearDataDialogue(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade800),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.blue,
                              ),
                            ),
                            15.widthBox,
                            Expanded(
                              child: Text(
                                LocaleKeys.clearData.tr,
                                style:
                                    TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 0.2,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: InkWell(
                        onTap: () {
                          _deleteAccountDialogue(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade800),
                              child: const Icon(
                                Icons.person_remove_alt_1_outlined,
                                color: Colors.redAccent,
                              ),
                            ),
                            15.widthBox,
                            Expanded(
                              child: Text(
                                LocaleKeys.deleteAccount.tr,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.heightBox
            ],
          ),
        ),
      ),
    );
  }

  Future<void> clearData() async {
    await databaseHelper.clearTransactionTable();
    MySharedPreferences.instance
        .addStringToSF(SharedPreferencesKeys.userEmail, "");
    MySharedPreferences.instance
        .addBoolToSF(SharedPreferencesKeys.isBudgetAdded, false);
    MySharedPreferences.instance
        .addBoolToSF(SharedPreferencesKeys.isLogin, false);
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => const BudgetScreen()));
  }

  Future<void> deleteAccount() async {
    await databaseHelper.clearAllTables();
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  Future<void> getProfileData() async {
    try {
      ProfileModel? fetchedProfileData =
          await databaseHelper.getProfileData(userEmail);
      setState(() {
        profileData = fetchedProfileData;
        fullName = "${profileData!.first_name!} ${profileData!.last_name!}";
        email = profileData!.email!;
        userCode = profileData!.user_code!;

        dob = profileData!.dob!;
        selectedValue =
            profileData!.gender == "" ? 'Female' : profileData!.gender!;
        isLoading = false;
      });
    } catch (error) {
      Helper.hideLoading(context);
      print('Error fetching Profile Data: $error');
      setState(() {
        isLoading = false;
      });
    }
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

  signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();

      MySharedPreferences.instance
          .addStringToSF(SharedPreferencesKeys.userEmail, "");
      MySharedPreferences.instance
          .addStringToSF(SharedPreferencesKeys.userName, "");
      MySharedPreferences.instance
          .addStringToSF(SharedPreferencesKeys.currentUserEmail, "");
      MySharedPreferences.instance
          .addStringToSF(SharedPreferencesKeys.currentUserName, "");
      MySharedPreferences.instance
          .addStringToSF(SharedPreferencesKeys.userFcmToken, "");
      MySharedPreferences.instance
          .addBoolToSF(SharedPreferencesKeys.isLogin, false);

      Get.offAll(SignInScreen());
      /* Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (context) => const SignInScreen()));*/
    } catch (e) {
      Helper.showToast('Error signing out. Try again.');
    }
  }

  Future _clearDataDialogue(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (cont) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          insetPadding: const EdgeInsets.all(15),
          backgroundColor: Helper.getCardColor(context),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(cont);
                    },
                    child:
                        Icon(Icons.close, color: Helper.getTextColor(context)),
                  ),
                ),
                10.heightBox,
                Text(
                  LocaleKeys.sureToClear.tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Helper.getTextColor(context),
                    fontSize: 20,
                  ),
                ),
                20.heightBox,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(cont);
                        },
                        child: Text(
                          LocaleKeys.no.tr,
                          style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      20.widthBox,
                      InkWell(
                        onTap: () {
                          clearData();
                          Navigator.pop(cont);
                        },
                        child: Text(
                          LocaleKeys.yes.tr,
                          style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _deleteAccountDialogue(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (cont) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          insetPadding: const EdgeInsets.all(15),
          backgroundColor: Helper.getCardColor(context),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(cont);
                    },
                    child:
                        Icon(Icons.close, color: Helper.getTextColor(context)),
                  ),
                ),
                10.heightBox,
                Text(
                  LocaleKeys.sureToDelete.tr,
                  style: TextStyle(
                    color: Helper.getTextColor(context),
                    fontSize: 20,
                  ),
                ),
                10.heightBox,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(cont);
                        },
                        child: Text(
                          LocaleKeys.no.tr,
                          style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      20.widthBox,
                      InkWell(
                        onTap: () async {
                          deleteAccount();
                          Navigator.pop(context);
                        },
                        child: Text(
                          LocaleKeys.yes.tr,
                          style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _logOutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (cont) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          insetPadding: const EdgeInsets.all(15),
          backgroundColor: Helper.getCardColor(context),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(cont);
                    },
                    child:
                        Icon(Icons.close, color: Helper.getTextColor(context)),
                  ),
                ),
                10.heightBox,
                Text(
                  LocaleKeys.sureToLogout.tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Helper.getTextColor(context),
                    fontSize: 20,
                  ),
                ),
                20.heightBox,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(cont);
                        },
                        child: Text(
                          LocaleKeys.no.tr,
                          style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      20.widthBox,
                      InkWell(
                        onTap: () async {
                          Navigator.pop(cont);
                          signOut();
                        },
                        child: Text(
                          LocaleKeys.yes.tr,
                          style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
