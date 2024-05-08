
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/master_password/master_password_screen.dart';
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
  List<List<dynamic>> data = [];

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
                                const BorderRadius.all(Radius.circular(10))),
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
                      InkWell(
                        onTap: (){
                          MyDialog().showMasterPasswordDialog( context: context, export: true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 5, top: 3, bottom: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Backup",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Helper.getTextColor(context)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Icon(Icons.arrow_forward_ios_outlined, size: 16,),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      20.heightBox,
                      InkWell(
                        onTap: (){
                          MyDialog().showMasterPasswordDialog(context: context, export: false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 5, top: 3, bottom: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Restore",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Helper.getTextColor(context)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Icon(Icons.arrow_forward_ios_outlined, size: 16,),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    /*  ListView.builder(
                        itemCount: data.length > 1 ? data.length - 1 : 0,
                        // Adjusted for skipping the header row
                        itemBuilder: (context, index) {
                          if (index >= data.length - 1) {
                            return const SizedBox(); // Return an empty SizedBox if the index is out of range
                          }
                          // Create a ToDoModel object from CSV data
                          TransactionModel todoModel = TransactionModel(
                            id: data[index + 1][0],
                            member_email: data[index + 1][1].toString(),
                            amount: data[index + 1][3].toString(),
                            cat_name: data[index + 1][4].toString(),
                            cat_type: data[index + 1][5], // Adjusted index and added 1 to skip the header row
                          );

                          return Dismissible(
                            key: Key(todoModel.id!),
                            // Use the ID as the key for Dismissible
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) {
                              // Remove the item from the database and reload the tasks
                              deleteToDoItem(todoModel.id!);
                            },
                            background: Container(
                              color: Colors.red,
                              // Background color when swiping
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ToDoItem(
                                toDoModel: todoModel,
                                onToDoChanged: handleToDoChange,
                                onDeleteItem: deleteToDoItem,
                                onPriorityChanged: handlePriorityChange,
                                isDarkMode: isDarkMode,
                                onMultipleDelete: onMultipleDelete,
                                isTaskSelected: isTaskSelected,
                              ),
                            ),
                          );
                        },
                      ),*/
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
