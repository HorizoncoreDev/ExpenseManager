import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/other_screen/family_account/family_account_screen.dart';
import 'package:expense_manager/other_screen/invite_friends_screen.dart';
import 'package:expense_manager/sign_in/sign_in_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/global.dart';
import 'account_detail/account_detail_screen.dart';
import 'bloc/other_bloc.dart';
import 'bloc/other_state.dart';
import 'category/category_screen.dart';
import 'general_setting/general_setting_screen.dart';
import 'my_library/my_library_screen.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {
  OtherBloc otherBloc = OtherBloc();

  List<GridItem> gridItemList = [
    // GridItem(iconData: Icons.account_circle, text: 'My family'),
    GridItem(iconData: Icons.settings, text: 'Category'),
    GridItem(iconData: Icons.settings, text: 'My Library'),
  ];

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;
  bool isSkippedUser = false;
  String userEmail = '';
  ProfileModel? profileData;
  int id = 0;
  String shortName = "";
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();


  @override
  void initState() {
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        setState(() {
          isSkippedUser = value;
        });
      }
    });
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
        getProfileData();
      }
    }); // TODO: implement initState
    super.initState();
  }

  Future<void> getProfileData() async {
    try {
      ProfileModel? fetchedProfileData =
      await databaseHelper.getProfileData(userEmail);
      setState(() {
        profileData = fetchedProfileData;
        id = profileData!.id!;
        firstNameController.text = profileData!.first_name!;
        lastNameController.text = profileData!.last_name!;
      }
      );
     shortName= Helper.getShortName(profileData!.first_name!, profileData!.last_name!);
    } catch (error) {
      print('Error fetching Profile Data: $error');
      /* setState(() {
        isLoading = false;
      });*/
    }
  }


  @override
  Widget build(BuildContext context) {
    otherBloc.context = context;
    return BlocConsumer<OtherBloc, OtherState>(
      bloc: otherBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is OtherInitial) {
          return SafeArea(
            child: Scaffold(
              body: Container(
                  color: Helper.getBackgroundColor(context),
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          10.heightBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Other",
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                              // if (!isSkippedUser)
                              InkWell(
                                onTap: () {
                                  if (isSkippedUser) {
                                    MySharedPreferences.instance.addBoolToSF(
                                        SharedPreferencesKeys.isSkippedUser,
                                        false);
                                    AppConstanst.signInClicked++;
                                    Helper.showToast(
                                        "Kindly proceed with your sign-in.");
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const SignInScreen()),
                                    );
                                  }
                                  else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const AccountDetailScreen()),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Helper.getCardColor(context)),
                                  child: Text(
                                    shortName == "" ? "AB" : shortName
                                        .characters.toString(),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          15.heightBox,
                          Text(
                            "MANAGE",
                            style: TextStyle(
                                fontSize: 14,
                                color: Helper.getTextColor(context),
                                fontWeight: FontWeight.bold),
                          ),
                          10.heightBox,
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Helper.getCardColor(context),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Row(
                              children: [
                                 InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FamilyAccountScreen()),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        decoration:  BoxDecoration(
                                            color: Colors.grey.shade800,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(10))),
                                        // alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.account_circle,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      5.heightBox,
                                      Text(
                                        'My Accounts',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Helper.getTextColor(context),
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                20.widthBox,
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const CategoryScreen()),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        decoration:  BoxDecoration(
                                            color: Colors.grey.shade800,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(10))),
                                        // alignment: Alignment.center,
                                        child:SvgPicture.asset(
                                          'asset/images/ic_categories.svg',
                                          color: Colors.blue,
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                      5.heightBox,
                                      Text(
                                        'Category',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Helper.getTextColor(context),
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                20.widthBox,
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const MyLibraryScreen()),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        decoration:  BoxDecoration(
                                            color: Colors.grey.shade800,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(10))),
                                        // alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          'asset/images/ic_library.svg',
                                          color: Colors.blue,
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                      5.heightBox,
                                      Text(
                                        'My Library',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Helper.getTextColor(context),
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          15.heightBox,
                          Text(
                            "APP",
                            style: TextStyle(
                                fontSize: 14,
                                color: Helper.getTextColor(context),
                                fontWeight: FontWeight.bold),
                          ),
                          10.heightBox,
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: Helper.getCardColor(context),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const GeneralSettingScreen()),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        15.widthBox,
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration:  BoxDecoration(
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
                                            "General settings",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Helper.getTextColor(
                                                    context)),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Helper.getTextColor(context),
                                          size: 16,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  thickness: 0.2,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: InkWell(
                                    onTap: () {
                                      requestContactPermission();

                                    },
                                    child: Row(
                                      children: [
                                        15.widthBox,
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration:  BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade800),
                                          child: SvgPicture.asset(
                                            'asset/images/ic_invite.svg',
                                            color: Colors.blue,
                                            height: 20,
                                            width: 20,
                                          ),
                                        ),
                                        15.widthBox,
                                        Expanded(
                                          child: Text(
                                            "Invite friends",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                Helper.getTextColor(context)),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Helper.getTextColor(context),
                                          size: 16,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  thickness: 0.2,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: InkWell(
                                    onTap: () {
                                      _rateAppDialogue(otherBloc);
                                    },
                                    child: Row(
                                      children: [
                                        15.widthBox,
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration:  BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade800),
                                          child: SvgPicture.asset(
                                            'asset/images/ic_rate.svg',
                                            color: Colors.blue,
                                            height: 20,
                                            width: 20,
                                          ),
                                        ),
                                        15.widthBox,
                                        Expanded(
                                          child: Text(
                                            "Rate the app",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Helper.getTextColor(
                                                    context)),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Helper.getTextColor(context),
                                          size: 16,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  thickness: 0.2,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      15.widthBox,
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration:  BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade800),
                                        child: SvgPicture.asset(
                                          'asset/images/ic_version.svg',
                                          color: Colors.blue,
                                          height: 22,
                                          width: 22,
                                        ),
                                      ),
                                      15.widthBox,
                                      Expanded(
                                        child: Text(
                                          "Version",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color:
                                              Helper.getTextColor(context)),
                                        ),
                                      ),
                                      Text(
                                        "1.0.0",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                            Helper.getTextColor(context)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.heightBox
                        ],
                      ),
                    ),
                  )),
            ),
          );
        }
        return Container();
      },
    );
  }

  Future _rateAppDialogue(OtherBloc otherBloc) async {

    await showDialog(
      context: otherBloc.context,
      builder: (cont) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          insetPadding: const EdgeInsets.all(15),
          backgroundColor: Helper.getCardColor(context),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(cont);
                        },
                        child: Icon(
                          Icons.close,
                          color: Helper.getTextColor(context),
                        ))),
                Text(
                  "Review",
                  style: TextStyle(
                      color: Helper.getTextColor(context),
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                30.heightBox,
                Text(
                  "Do you like this app?",
                  style: TextStyle(
                    color: Helper.getTextColor(context),
                    fontSize: 16,
                  ),
                ),
                30.heightBox,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                            size: 50,
                          ),
                          Text(
                            "No",
                            style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_circle,
                              color: Colors.grey,
                              size: 50,
                            ),
                            Text(
                              "Like",
                              style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )),
                    Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_circle,
                              color: Colors.grey,
                              size: 50,
                            ),
                            Text(
                              "Like so much",
                              style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
                30.heightBox,
                RichText(
                    text: TextSpan(
                        text: "Please leave a review ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Helper.getTextColor(context),
                        ),
                        children: [
                          const TextSpan(
                            text: "5 stars ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: "for this app on the AppStore?",
                            style: TextStyle(
                              fontSize: 16,
                              color: Helper.getTextColor(context),
                            ),
                          ),
                        ])),
                30.heightBox,
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: const Text(
                      "Rate the app",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                10.heightBox,
                Text(
                  "Your 5 star review is a great reward to us!",
                  style: TextStyle(
                    color: Helper.getTextColor(context),
                    fontSize: 12,
                  ),
                ),
                10.heightBox,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> requestContactPermission() async {
      PermissionStatus status = await Permission.contacts.status;
      if(!status.isGranted){
        status = await Permission.contacts.request();
      }
      if (status.isGranted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=> const InviteFriendsScreen()));
      }
      else if(status.isPermanentlyDenied){
        openAppSettings();
        Helper.showToast("Permission is permanently denied");
      }
      else{
        Helper.showToast("Please allow to access contacts!!");
      }
  }

}

class GridItem {
  final IconData iconData;
  final String text;

  GridItem({required this.iconData, required this.text});
}

