import 'package:expense_manager/dashboard/dashboard.dart';
import 'package:expense_manager/sign_in/bloc/bloc.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../budget/budget_screen.dart';
import '../db_models/profile_model.dart';
import '../db_service/database_helper.dart';
import '../utils/global.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  SignInBloc signInBloc = SignInBloc();

  final FirebaseAuth auth = FirebaseAuth.instance;

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    signInBloc.context = context;
    return BlocConsumer<SignInBloc, SignInState>(
      bloc: signInBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SignInInitial) {
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
                              const Text(
                                "Smart Expensee",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500),
                              ),
                              15.heightBox,
                              const Text(
                                "Login to sync data across multiple devices and\nexperience our many exciting features",
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
                                    "Sign in with Google",
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const BudgetScreen()));
                                },
                                child: Text(
                                  "Skip",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 16),
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
        return Container();
      },
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

                    final reference = FirebaseDatabase.instance
                        .reference()
                        .child(profile_table);
                    var newPostRef = reference.push();

                    ProfileModel profileModel =  ProfileModel(
                        key: newPostRef.key,
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
                        fcm_token: fcmToken);
                    await databaseHelper.insertProfileData(
                        profileModel
                    );


                    newPostRef.set(
                      profileModel.toMap(),
                    );
                  });
                });
              });
            });

            await DatabaseHelper.instance
                .getTransactionList("", "", -1)
                .then((value) async {
              for (var t in value) {
                t.member_id = 1;
                t.member_email = user.email;
                await databaseHelper.updateTransaction(t);
              }
            });

            MySharedPreferences.instance
                .addStringToSF(SharedPreferencesKeys.userEmail, user.email);
            MySharedPreferences.instance
                .addStringToSF(SharedPreferencesKeys.userName, user.displayName);
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
                MaterialPageRoute(builder: (context) => const DashBoard()),
                    (Route<dynamic> route) => false);
          } else {
            await DatabaseHelper.instance
                .getProfileData(user.email!)
                .then((profileData) async {
              if (profileData == null) {
                String userCode = await Helper.generateUniqueCode();

                MySharedPreferences.instance
                    .getStringValuesSF(SharedPreferencesKeys.userFcmToken)
                    .then((value) async {
                  fcmToken = value!;

                  final reference = FirebaseDatabase.instance
                      .reference()
                      .child(profile_table);
                  var newPostRef = reference.push();

                  ProfileModel profileModel = ProfileModel(
                      key: newPostRef.key,
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
                      fcm_token: fcmToken);
                  await databaseHelper.insertProfileData(
                      profileModel
                  );

                  newPostRef.set(profileModel.toMap());

                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.userEmail, user.email);
                  MySharedPreferences.instance.addStringToSF(
                      SharedPreferencesKeys.userName, user.displayName);
                  MySharedPreferences.instance
                      .addBoolToSF(SharedPreferencesKeys.isLogin, true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BudgetScreen()),
                  );
                });
              } else {
                MySharedPreferences.instance
                    .addStringToSF(SharedPreferencesKeys.userEmail, user.email);
                MySharedPreferences.instance
                    .addStringToSF(SharedPreferencesKeys.userName, user.displayName);
                MySharedPreferences.instance
                    .addBoolToSF(SharedPreferencesKeys.isLogin, true);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashBoard()),
                        (Route<dynamic> route) => false);
              }
            });
          }
        }
      }
    } catch (e) {
      Helper.showToast("some error occured $e");
    }
  }
}
