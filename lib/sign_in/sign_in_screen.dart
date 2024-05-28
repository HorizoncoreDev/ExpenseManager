import 'package:expense_manager/dashboard/dashboard.dart';
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../budget/budget_screen.dart';
import '../db_models/accounts_model.dart';
import '../db_models/profile_model.dart';
import '../db_service/database_helper.dart';
import '../utils/global.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;
  String languageCode = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Helper.getBackgroundColor(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                child: Column(
                  children: [
                    20.heightBox,
                    Text(
                      LocaleKeys.smartExpense.tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w500),
                    ),
                    15.heightBox,
                    Text(
                      LocaleKeys.loginText.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    15.heightBox,
                    Image.asset(
                      ImageConstanst.icPhone,
                      height: 350,
                      width: 350,
                    )
                  ],
                ),
              ),
              20.heightBox,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: InkWell(
                  onTap: () {
                    googleSignup();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                        color: Helper.getCardColor(context),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          ImageConstanst.icGoogle,
                          width: 18,
                          height: 18,
                        ),
                        15.widthBox,
                        Text(
                          LocaleKeys.signIn.tr,
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /*15.heightBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: InkWell(
                            onTap: (){
                              signInWithFacebook();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                              decoration: const BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(ImageConstanst.icFacebook,color: Colors.blueAccent,),
                                  15.widthBox,
                                  const Text("Sign in with Facebook",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    ),),
                                ],
                              ),
                            ),
                          ),
                        ),

                        15.heightBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                            decoration: const BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(ImageConstanst.icApple,color: Colors.white,),
                                15.widthBox,
                                const Text("Sign in with Apple",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14
                                  ),),
                              ],
                            ),
                          ),
                        ),*/

              30.heightBox,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        MySharedPreferences.instance.addBoolToSF(
                            SharedPreferencesKeys.isSkippedUser, true);
                        if (AppConstanst.signInClicked == 1) {
                          AppConstanst.signInClicked = 0;
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DashBoard()),
                              (Route<dynamic> route) => false);
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BudgetScreen()));
                        }
                      },
                      child: Text(
                        LocaleKeys.skip.tr,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 16),
                      ),
                    ),
                    3.widthBox,
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Helper.getTextColor(context),
                      size: 10,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  Future<void> googleSignup() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        // Getting users credential
        UserCredential? result =
            await auth.signInWithCredential(authCredential);
        User? user = result.user;

        if (user != null) {
          // Extracting first and last names from displayName
          List<String> names = user.displayName?.split(" ") ?? [];
          String firstName = names.isNotEmpty ? names[0] : "";
          String lastName = names.length > 1 ? names.last : "";
          MySharedPreferences.instance
              .addBoolToSF(SharedPreferencesKeys.isSkippedUser, false);

          var currentBalance = "0";
          var currentIncome = "0";
          var currentActualBudget = "0";
          var fcmToken = "";

          if (AppConstanst.signInClicked == 1) {
            AppConstanst.signInClicked = 0;
            MySharedPreferences.instance
                .getStringValuesSF(
                    SharedPreferencesKeys.skippedUserCurrentBalance)
                .then((value) {
              currentBalance = value!;
              MySharedPreferences.instance
                  .getStringValuesSF(
                      SharedPreferencesKeys.skippedUserCurrentIncome)
                  .then((value) {
                currentIncome = value!;
                MySharedPreferences.instance
                    .getStringValuesSF(
                        SharedPreferencesKeys.skippedUserActualBudget)
                    .then((value) async {
                  currentActualBudget = value!;
                  MySharedPreferences.instance
                      .getStringValuesSF(SharedPreferencesKeys.userFcmToken)
                      .then((value) async {
                    fcmToken = value!;

                    String userCode = await Helper.generateUniqueCode();

                    ProfileModel profileModel = ProfileModel(
                      key: FirebaseAuth.instance.currentUser!.uid,
                      first_name: firstName,
                      last_name: lastName,
                      email: user.email ?? "",
                      full_name: user.displayName ?? "",
                      dob: "",
                      user_code: userCode,
                      profile_image: "",
                      mobile_number: "",
                      current_balance: currentBalance,
                      current_income: currentIncome,
                      actual_budget: currentActualBudget,
                      gender: "",
                      fcm_token: fcmToken,
                      lang_code: languageCode,
                      currency_code: "",
                      currency_symbol: "",
                        register_type: AppConstanst.gmailRegistration,
                        register_otp: "",
                        created_at: DateTime.now().toString(),
                        updated_at: DateTime.now().toString()
                    );

                    AccountsModel accountsModel = AccountsModel(
                        account_name:user.displayName,
                        description:"",
                        budget:currentActualBudget,
                        balance:currentBalance,
                        income: currentIncome,
                        balance_date:DateTime.now().toString(),
                        account_status:AppConstanst.activeAccount,
                        created_at: DateTime.now().toString(),
                        updated_at: DateTime.now().toString()
                    );

                    await databaseHelper.insertProfileData(profileModel, false,accountsModel);

                    final reference = FirebaseDatabase.instance
                        .reference()
                        .child(accounts_table)
                        .orderByChild(AccountTableFields.key)
                        .equalTo(FirebaseAuth.instance.currentUser!.uid);

                    reference.onValue.listen((event) {
                      DataSnapshot dataSnapshot = event.snapshot;
                      if (event.snapshot.exists) {
                        Map<dynamic, dynamic> values =
                        dataSnapshot.value as Map<dynamic, dynamic>;
                        values.forEach((key, value) async {
                          await DatabaseHelper.instance
                              .getTransactionList("", "", "", -1, true)
                              .then((value) async {
                            for (var t in value) {
                              // t.member_id = 1;
                              t.member_key = FirebaseAuth.instance.currentUser!.uid;
                              t.account_key = key;
                              await databaseHelper.updateTransaction(t);

                              final reference = FirebaseDatabase.instance
                                  .reference()
                                  .child(transaction_table)
                                  .child(FirebaseAuth.instance.currentUser!.uid);
                              var newPostRef = reference.push();
                              t.key = newPostRef.key;
                              newPostRef.set(
                                t.toMap(),
                              );
                            }
                          });
                        });
                      }
                    });

                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.userEmail, user.email);
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.currentUserEmail, user.email);

                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.currentUserKey,
                        FirebaseAuth.instance.currentUser!.uid);
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.userName, user.displayName);
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.currentUserName,
                        user.displayName);
                    MySharedPreferences.instance
                        .addBoolToSF(SharedPreferencesKeys.isLogin, true);
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentBalance, "0");
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentIncome, "0");
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserActualBudget, "0");

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashBoard()),
                        (Route<dynamic> route) => false);
                  });
                });
              });
            });
          } else {
            MySharedPreferences.instance
                .getStringValuesSF(SharedPreferencesKeys.userFcmToken)
                .then((value) async {
              fcmToken = value!;

              final reference = FirebaseDatabase.instance
                  .reference()
                  .child(profile_table)
                  .orderByChild('email')
                  .equalTo(user.email!);
              bool calledOnce = false, profileCheckCalledOnce = false;
              reference.once().then((event) async {
                DataSnapshot dataSnapshot = event.snapshot;
                if (event.snapshot.exists && !profileCheckCalledOnce) {
                  ProfileModel? profileModel;
                  AccountsModel? accountsModel;
                  Map<dynamic, dynamic> values =
                      dataSnapshot.value as Map<dynamic, dynamic>;
                  values.forEach((key, value) async {
                    profileModel = ProfileModel.fromMap(value);

                    profileModel!.fcm_token = fcmToken;
                    final Map<String, Map> updates = {};
                    updates['/$profile_table/${profileModel!.key}'] =
                        profileModel!.toMap();
                    FirebaseDatabase.instance.ref().update(updates);

                     /*accountsModel = AccountsModel(
                        account_name:value[ProfileTableFields.full_name],
                        description:"",
                        budget:value[ProfileTableFields.actual_budget],
                        balance:value[ProfileTableFields.current_balance],
                        income: value[ProfileTableFields.current_income],
                        balance_date:DateTime.now().toString(),
                        account_status:AppConstanst.activeAccount,
                        created_at: DateTime.now().toString(),
                        updated_at: DateTime.now().toString()
                    );*/

                  });

                  await databaseHelper
                      .getProfileData(user.email!)
                      .then((profileData) async {
                    if (profileData != null) {
                      // profileModel!.id = profileData.id;
                      await databaseHelper.updateProfileData(profileModel!);
                      //await databaseHelper.updateAccountData(accountsModel!);
                    } else {
                      if (!calledOnce) {
                        calledOnce = true;
                        await databaseHelper.insertProfileData(
                            profileModel!, true,accountsModel);
                      }
                    }
                  });
                  await databaseHelper
                      .getProfileData(user.email!)
                      .then((profileData) async {
                    if (profileData != null) {
                      // profileModel!.id = profileData.id;
                      await databaseHelper.updateProfileData(profileModel!);
                      //await databaseHelper.updateAccountData(accountsModel!);
                    } else {
                      if (!calledOnce) {
                        calledOnce = true;
                        await databaseHelper.insertProfileData(
                            profileModel!, true,accountsModel);
                      }
                    }
                  });

                  final reference = FirebaseDatabase.instance
                      .reference()
                      .child(accounts_table)
                      .child(profileModel!.key!);

                  reference.once().then((event) async {
                    DataSnapshot dataSnapshot = event.snapshot;
                    if (event.snapshot.exists) {
                      Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
                      values.forEach((key, value) async {
                        MySharedPreferences.instance.addStringToSF(
                            SharedPreferencesKeys.currentAccountKey, key);
                      });
                    }
                  });



                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.userEmail, user.email);

                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.currentUserEmail, user.email);
                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.currentUserKey,
                      FirebaseAuth.instance.currentUser!.uid);

                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.currentUserName, user.displayName);
                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.userName, user.displayName);
                  MySharedPreferences.instance
                      .addBoolToSF(SharedPreferencesKeys.isLogin, true);
                  if (profileModel!.actual_budget == "0") {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BudgetScreen()),
                        (Route<dynamic> route) => false);
                  } else {
                    MySharedPreferences.instance
                        .addBoolToSF(SharedPreferencesKeys.isBudgetAdded, true);

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashBoard()),
                        (Route<dynamic> route) => false);
                  }
                } else {
                  if (!profileCheckCalledOnce) {
                    profileCheckCalledOnce = true;
                    String userCode = await Helper.generateUniqueCode();
                    ProfileModel profileModel = ProfileModel(
                      key: FirebaseAuth.instance.currentUser!.uid,
                      first_name: firstName,
                      last_name: lastName,
                      email: user.email ?? "",
                      full_name: user.displayName ?? "",
                      dob: "",
                      user_code: userCode,
                      profile_image: "",
                      mobile_number: "",
                      current_balance: "0",
                      current_income: "0",
                      actual_budget: "0",
                      gender: "",
                      fcm_token: fcmToken,
                      lang_code: languageCode,
                      currency_code: "",
                      currency_symbol: "",
                      register_type: AppConstanst.gmailRegistration,
                      register_otp: "",
                      created_at: DateTime.now().toString(),
                      updated_at: DateTime.now().toString()
                    );

                    AccountsModel accountsModel = AccountsModel(
                    account_name:user.displayName,
                    description:"",
                    budget:"0",
                    balance:"0",
                    income: "0",
                    balance_date:DateTime.now().toString(),
                    account_status:AppConstanst.activeAccount,
                    created_at: DateTime.now().toString(),
                    updated_at: DateTime.now().toString()
                    );

                    await databaseHelper.insertProfileData(profileModel, false,accountsModel);

                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.userEmail, user.email);
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.userName, user.displayName);
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.currentUserEmail, user.email);
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.currentUserKey,
                        FirebaseAuth.instance.currentUser!.uid);

                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.currentUserName,
                        user.displayName);
                    MySharedPreferences.instance
                        .addBoolToSF(SharedPreferencesKeys.isLogin, true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BudgetScreen()),
                    );
                  }
                }
              });
            });
          }
        }
      }
    } catch (e) {
      Helper.showToast("some error occured $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.languageCode)
        .then((value) {
      if (value != null) {
        languageCode = value;
      }
    });
  }
}
