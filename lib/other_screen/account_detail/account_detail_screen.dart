import 'dart:ui';

import 'package:expense_manager/utils/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../db_models/profile_model.dart';
import '../../db_service/database_helper.dart';
import '../../sign_in/sign_in_screen.dart';
import '../../utils/global.dart';
import '../../utils/helper.dart';
import '../edit_account_detail/edit_account_detail_screen.dart';
import 'bloc/account_detail_bloc.dart';
import 'bloc/account_detail_state.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({super.key});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {

  AccountDetailBloc accountDetailBloc = AccountDetailBloc();
  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  String? dateOfBirth;
  String dob = "";

  String selectedValue = 'Female';
  List<String> dropdownItems = ['Male', 'Female'];

  bool emailIsValid = false;
  String shortName = "";
  String fullName = "";
  String email = "";
  bool isLoading = true;

  List<ProfileModel> profileData = [];

  String getShortName(String name, String name1) {

    String firstStr = name.split(" ").first;
    String secondStr = name1.split(" ").first;

    String firstChar = firstStr.substring(0, 1);
    String secondChar = secondStr.substring(0, 1);

    return shortName = firstChar + secondChar;
  }

  Future<void> getProfileData() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      List<ProfileModel> fetchedProfileData = await databaseHelper.getProfileData();
      setState(() {
        profileData = fetchedProfileData;
        fullName = profileData[0].first_name!;
        email = profileData[0].email!;

        dob = profileData[0].dob!;
        selectedValue = profileData[0].gender==""?'Female':profileData[0].gender!;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching Profile Data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    accountDetailBloc.context = context;
    return BlocConsumer<AccountDetailBloc, AccountDetailState>(
      bloc: accountDetailBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is AccountDetailInitial){
          return Scaffold(
            appBar: AppBar(
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios,color: Colors.white,size: 18,)),
              backgroundColor: Colors.black87,
              titleSpacing: 0.0,
              title: const Text("Account Details",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white)),
              elevation: 0.0,
              actions: [
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditAccountDetailScreen()),
                    );
                  },
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10
                      ),
                      child: const Icon(Icons.edit,color: Colors.white,)
                  ),
                ),
                10.widthBox
              ],
            ),
            body: Container(
              color: Colors.black87,
              height: double.infinity,
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.heightBox,
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                      decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(
                              Radius.circular(10))
                      ),
                      child: Row(
                        children: [
                          10.widthBox,
                          Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white70),
                              ),
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  margin: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white70),
                                  child: const Center(
                                      child: Icon(Icons.person,color: Colors.grey,size: 35,)))),
                          20.widthBox,
                           Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fullName??"",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                    )),
                                Text(email??"",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.heightBox,
                    const Text("ACCOUNT",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold
                      ),),

                    5.heightBox,
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blueGrey
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.blue,
                                  ),
                                ),
                                15.widthBox,
                                const Expanded(
                                  child: Text("Account linked",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white
                                    ),),
                                ),
                                SvgPicture.asset(ImageConstanst.icGoogle,width:24,height: 24,),
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
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blueGrey
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.blue,
                                  ),
                                ),
                                15.widthBox,
                                const Expanded(
                                  child: Text("User code",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white
                                    ),),
                                ),
                                const Text("EZR64Q",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 17
                                  ),),
                                5.widthBox,
                                const Icon(
                                  Icons.copy_rounded,
                                  color: Colors.blue,
                                  size: 16  ,
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 0.2,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: InkWell(
                              onTap: () async{
                                /*await signOut();*/

                                /*Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => SignInScreen()));*/
                              },
                              child: Row(
                                children: [

                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blueGrey
                                    ),
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  15.widthBox,
                                  const Expanded(
                                    child: Text("Logout",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white
                                      ),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    20.heightBox,
                    const Text("USER DATA",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold
                      ),),

                    5.heightBox,
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: InkWell(
                              onTap: (){
                                _clearDataDialogue(accountDetailBloc);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blueGrey
                                    ),
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  15.widthBox,
                                  const Expanded(
                                    child: Text("Clear data, refresh application",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue
                                      ),),
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
                              onTap: (){
                                _deleteAccountDialogue(accountDetailBloc);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blueGrey
                                    ),
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  15.widthBox,
                                  const Expanded(
                                    child: Text("Delete account, stop using",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.redAccent
                                      ),),
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
        return Container();
      },
    );
  }

  Future _deleteAccountDialogue(AccountDetailBloc accountDetailBloc) async {
    await showDialog(
      context: accountDetailBloc.context,
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
          backgroundColor: Colors.black,
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
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ),
                10.heightBox,
                const Text(
                  "Are you sure you want to delete this account?",
                  style: TextStyle(
                    color: Colors.white,
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
                        onTap: (){
                          Navigator.pop(cont);
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      20.widthBox,
                      InkWell(
                        onTap: (){
                          Navigator.pop(cont);
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.white,
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

  Future _clearDataDialogue(AccountDetailBloc accountDetailBloc) async {
    await showDialog(
      context: accountDetailBloc.context,
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
          backgroundColor: Colors.black,
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
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ),
                10.heightBox,
                const Text(
                  "Are you sure you want to clear data?",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
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
                        onTap: (){
                          Navigator.pop(cont);
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      20.widthBox,
                      InkWell(
                        onTap: (){
                          Navigator.pop(cont);
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.white,
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

 signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
    } catch (e) {
      Helper.showToast('Error signing out. Try again.');
    }
  }

}
