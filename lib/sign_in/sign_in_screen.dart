import 'package:expense_manager/sign_in/bloc/bloc.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../budget/budget_screen.dart';
import '../db_models/profile_model.dart';
import '../db_service/database_helper.dart';
import '../utils/global.dart';
import '../utils/helper.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  SignInBloc signInBloc = SignInBloc();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FacebookLogin facebookLogin = FacebookLogin();

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  late User? _user;

  @override
  Widget build(BuildContext context) {
    signInBloc.context = context;
    return BlocConsumer<SignInBloc, SignInState>(
      bloc: signInBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is SignInInitial){
          return SafeArea(
            child: Scaffold(
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black87,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                  bottomLeft:Radius.circular(15),
                                  bottomRight: Radius.circular(15))
                          ),
                          child: Column(
                            children: [
                              20.heightBox,
                              const Text("Smart Expensee",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500
                                ),),

                              15.heightBox,
                              const Text("Login to sync data across multiple devices and\nexperience our many exciting features",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),),

                              15.heightBox,
                              Image.asset(ImageConstanst.icPhone,
                                height: 350,
                                width: 350,)
                            ],
                          ),
                        ),

                        20.heightBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: InkWell(
                            onTap: (){
                              googleSignup();
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
                                  SvgPicture.asset(ImageConstanst.icGoogle,width:18,height: 18,),
                                  15.widthBox,
                                  const Text("Sign in with Google",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    ),),
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
                          padding: const EdgeInsets.symmetric(horizontal:25),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){
                                  signInBloc.add(SignInSkipEvent());
                                },
                                child: const Text("Skip",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16
                                  ),),
                              ),
                              3.widthBox,
                              const Icon(Icons.arrow_forward_ios_outlined,color: Colors.white,size: 10,)
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

    try{

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        // Getting users credential
        UserCredential? result = await auth.signInWithCredential(authCredential);
        User? user = result.user;

        if (user != null) {
          setState(() {
            _user = user;
          });
          // Extracting first and last names from displayName
          List<String> names = user.displayName?.split(" ") ?? [];
          String firstName = names.isNotEmpty ? names[0] : "";
          String lastName = names.length > 1 ? names.last : "";

            // Insert Profile Data
            await databaseHelper.insertProfileData(
              ProfileModel(id: 0,
                  first_name: firstName,
                           last_name: lastName,
                           email: user.email ?? "",
                           full_name: user.displayName ?? "",
                           dob: "",
                           profile_image: "",
                           mobile_number: "",
                           gender: ""),
            );


          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BudgetScreen()));
        }
      }

    }catch(e) {
      Helper.showToast("some error occured $e");
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final AccessToken accessToken = loginResult.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
        return await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        throw FirebaseAuthException(
          code: 'Facebook Login Failed',
          message: 'The Facebook login was not successful.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication exceptions
      print('Firebase Auth Exception: ${e.message}');
      throw e; // rethrow the exception
    } catch (e) {
      // Handle other exceptions
      print('Other Exception: $e');
      throw e; // rethrow the exception
    }
  }

}
