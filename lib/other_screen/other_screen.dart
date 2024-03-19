import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/global.dart';
import '../utils/my_shared_preferences.dart';
import 'account_detail/account_detail_screen.dart';
import 'bloc/other_bloc.dart';
import 'bloc/other_state.dart';
import 'category/category_screen.dart';
import 'family_account/family_account_screen.dart';
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

  bool isSkippedUser = false;

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
    }); // TODO: implement initState
    super.initState();
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
                  color: Colors.black87,
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
                              const Text(
                                "Other",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                              if(!isSkippedUser)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AccountDetailScreen()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey),
                                  child: const Text(
                                    "MB",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          /*20.heightBox,
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          borderRadius: BorderRadius.only(
                              topRight:Radius.circular(10),
                          topLeft: Radius.circular(10))
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
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Muskan Bhatt",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      )),
                                  Text("muskanbhatt13@gmail.com",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                      )),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward,color: Colors.white,size: 20,)
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.only(
                                bottomLeft:Radius.circular(10),
                                bottomRight: Radius.circular(10))
                        ),
                        child: Row(
                          children: [
                            const Padding(
                        padding:  EdgeInsets.only(top: 5,bottom: 5,left: 35,right: 20),
                              child: Text("FREE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11
                              ),),
                            ),
                            Container(
                              height: 26,
                              width: 1, // Width of the divider
                              color: Colors.grey,
                            ),
                            12.widthBox,
                            Expanded(
                              child: RichText(
                                  text: const TextSpan(
                                      text: "Maximum spending 17,000",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,),
                                      children: [
                                        TextSpan(
                                            text: " / month",
                                            style: TextStyle(
                                                fontSize:8,
                                                color: Colors.white,)),
                                      ])),
                            ),
                            const Padding(
                              padding:  EdgeInsets.only(top: 5,bottom: 5,left: 35,right: 20),
                              child: Icon(Icons.arrow_forward_ios,color: Colors.white,size: 15,),
                            )
                          ],
                        ),
                      ),*/

                          15.heightBox,
                          const Text(
                            "MANAGE",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          10.heightBox,
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                                color: Colors.white10,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
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
                                        decoration: const BoxDecoration(
                                            color: Colors.blueGrey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        // alignment: Alignment.center,
                                        child: Icon(
                                          Icons.account_circle,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      5.heightBox,
                                      Text(
                                        'My family',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
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
                                        decoration: const BoxDecoration(
                                            color: Colors.blueGrey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        // alignment: Alignment.center,
                                        child: Icon(
                                          Icons.settings,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      5.heightBox,
                                      Text(
                                        'Category',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
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
                                        decoration: const BoxDecoration(
                                            color: Colors.blueGrey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        // alignment: Alignment.center,
                                        child: Icon(
                                          Icons.settings,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      5.heightBox,
                                      Text(
                                        'My Library',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
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
                          const Text(
                            "APP",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          10.heightBox,
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                                color: Colors.white10,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
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
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blueGrey),
                                          child: const Icon(
                                            Icons.settings,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        15.widthBox,
                                        const Expanded(
                                          child: Text(
                                            "General settings",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
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
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blueGrey),
                                        child: const Icon(
                                          Icons.settings,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      15.widthBox,
                                      const Expanded(
                                        child: Text(
                                          "Invite friends",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    ],
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
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blueGrey),
                                          child: const Icon(
                                            Icons.settings,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        15.widthBox,
                                        const Expanded(
                                          child: Text(
                                            "Rate the app",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
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
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blueGrey),
                                        child: const Icon(
                                          Icons.settings,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      15.widthBox,
                                      const Expanded(
                                        child: Text(
                                          "Version",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Text(
                                        "2.0.1",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
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
          backgroundColor: Colors.black,
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
                          color: Colors.grey,
                        ))),
                Text(
                  "Review",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                30.heightBox,
                Text(
                  "Do you like this app?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                30.heightBox,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                            size: 50,
                          ),
                          Text(
                            "No",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                          size: 50,
                        ),
                        Text(
                          "Like",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      children: [
                        Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                          size: 50,
                        ),
                        Text(
                          "Like so much",
                          style: TextStyle(
                            color: Colors.white,
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
                          color: Colors.white,
                        ),
                        children: [
                      TextSpan(
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
                          color: Colors.white,
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
                    color: Colors.white,
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
}

class GridItem {
  final IconData iconData;
  final String text;

  GridItem({required this.iconData, required this.text});
}
