import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

import 'bloc/general_setting_bloc.dart';
import 'bloc/general_setting_state.dart';

class GeneralSettingScreen extends StatefulWidget {
  const GeneralSettingScreen({super.key});

  @override
  State<GeneralSettingScreen> createState() => _GeneralSettingScreenState();
}

class _GeneralSettingScreenState extends State<GeneralSettingScreen> {
  GeneralSettingBloc generalSettingBloc = GeneralSettingBloc();
  late ThemeNotifier _themeNotifier;

  bool isNotificationStatus = false;
  bool isSecurityCode = false;
  bool themeMode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    generalSettingBloc.context = context;

    /*_themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkMode = _themeNotifier.isDarkMode;*/

    return BlocConsumer<GeneralSettingBloc, GeneralSettingState>(
      bloc: generalSettingBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is GeneralSettingInitial) {
          return Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                backgroundColor: Helper.getBackgroundColor(context),
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Helper.getTextColor(context),
                    )),
                title: Text(
                  "General Settings",
                  style: TextStyle(
                      color: Helper.getTextColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: Helper.getBackgroundColor(context),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.heightBox,
                      Text(
                        "DISPLAY",
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 5, top: 3, bottom: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Dark mode",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Helper.getTextColor(context)),
                                    ),
                                  ),
                                  FlutterSwitch(
                                    width: 40,
                                    height: 20,
                                    padding: 1,
                                    value:
                                        _themeNotifier.getTheme().brightness ==
                                            Brightness.dark,
                                    borderRadius: 30.0,
                                    toggleColor: Colors.black,
                                    toggleSize: 15,
                                    switchBorder: Border.all(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.grey,
                                    onToggle: (val) {
                                      setState(() {
                                        if (val) {
                                          _themeNotifier.setDarkMode();
                                        } else {
                                          _themeNotifier.setLightMode();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: Colors.black12,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 5, top: 3, bottom: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Language",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Helper.getTextColor(context)),
                                    ),
                                  ),
                                  Text(
                                    "English",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Helper.getTextColor(context)),
                                  ),
                                  5.widthBox,
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: Colors.black12,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 5, top: 3, bottom: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Currency",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Helper.getTextColor(context)),
                                    ),
                                  ),
                                  Text(
                                    "INR",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Helper.getTextColor(context)),
                                  ),
                                  5.widthBox,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      20.heightBox,
                      /*Text(
                        "REMINDER",
                        style: TextStyle(
                            fontSize: 14,
                            color: Helper.getTextColor(context),
                            fontWeight: FontWeight.bold),
                      ),
                      5.heightBox,
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueGrey),
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            20.widthBox,
                            Expanded(
                              child: Text(
                                "Notification",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Helper.getTextColor(context)),
                              ),
                            ),
                            FlutterSwitch(
                              width: 40,
                              height: 20,
                              padding: 1,
                              value: isNotificationStatus,
                              borderRadius: 30.0,
                              toggleColor: Colors.black,
                              toggleSize: 15,
                              switchBorder: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              onToggle: (val) {
                                setState(() {
                                  isNotificationStatus = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      20.heightBox,
                      Text(
                        "SECURE",
                        style: TextStyle(
                            fontSize: 14,
                            color: Helper.getTextColor(context),
                            fontWeight: FontWeight.bold),
                      ),
                      5.heightBox,
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueGrey),
                              child: const Icon(
                                Icons.key_rounded,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            20.widthBox,
                            Expanded(
                              child: Text(
                                "Security code",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Helper.getTextColor(context)),
                              ),
                            ),
                            FlutterSwitch(
                              width: 40,
                              height: 20,
                              padding: 1,
                              value: isSecurityCode,
                              borderRadius: 30.0,
                              toggleColor: Colors.black,
                              toggleSize: 15,
                              switchBorder: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              onToggle: (val) {
                                setState(() {
                                  isSecurityCode = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      10.heightBox*/
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
