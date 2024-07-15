import 'package:expense_manager/db_models/currency_category_model.dart';
import 'package:expense_manager/db_models/language_category_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/master_password/master_password_screen.dart';
import 'package:expense_manager/other_screen/general_setting/currency_bottom_sheet.dart';
import 'package:expense_manager/other_screen/general_setting/lang_bottom_sheet.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GeneralSettingScreen extends StatefulWidget {
  const GeneralSettingScreen({super.key});

  @override
  State<GeneralSettingScreen> createState() => _GeneralSettingScreenState();
}

class _GeneralSettingScreenState extends State<GeneralSettingScreen> {
  late ThemeNotifier _themeNotifier;

  bool isNotificationStatus = false;
  bool isSecurityCode = false;
  bool themeMode = false;
  List<List<dynamic>> data = [];
  bool _backUpTileExpanded = false;
  List<LanguageCategory> languageTypes = [];
  final databaseHelper = DatabaseHelper.instance;
  String? language = "";
  String? langCode = "";
  LanguageCategory? selectedLanguage;
  List<CurrencyCategory> currencyTypes = [];
  int selectedCurrency = -1;
  int selectedLang = -1;
  String cCode = "";
  String cSymbol = "";

  String codeFromBottomSheet = "";

  @override
  Widget build(BuildContext context) {
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
            LocaleKeys.generalSettings.tr,
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
                  LocaleKeys.display.tr,
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
                                LocaleKeys.darkMode.tr,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Helper.getTextColor(context)),
                              ),
                            ),
                            FlutterSwitch(
                              width: 40,
                              height: 20,
                              padding: 1,
                              value: _themeNotifier.getTheme().brightness ==
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
                          child: InkWell(
                            onTap: () {
                              languageBottomSheet();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    LocaleKeys.language.tr,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Helper.getTextColor(context)),
                                  ),
                                ),
                                Text(
                                  language!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Helper.getTextColor(context)),
                                ),
                                5.widthBox,
                              ],
                            ),
                          )),
                      const Divider(
                        thickness: 1,
                        color: Colors.black12,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 5, top: 3, bottom: 3),
                        child: InkWell(
                          onTap: () {
                            currencyBottomSheet();
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  LocaleKeys.currency.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Helper.getTextColor(context)),
                                ),
                              ),
                              Text(
                                codeFromBottomSheet.isEmpty
                                    ? AppConstanst.currencyCode
                                    : codeFromBottomSheet,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Helper.getTextColor(context)),
                              ),
                              5.widthBox,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                20.heightBox,
                Container(
                  decoration: BoxDecoration(
                      color: Helper.getCardColor(context),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        LocaleKeys.backUp.tr,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 16),
                      ),
                      trailing: Icon(
                        !_backUpTileExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up_rounded,
                        color: Helper.getTextColor(context),
                      ),
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _backUpTileExpanded = expanded;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  MasterPasswordDialog()
                                      .showMasterPasswordDialog(
                                          context: context,
                                          export: true,
                                          backupType: "CSV");
                                },
                                child: Row(
                                  children: [
                                    Container(
                                        height: 38,
                                        width: 38,
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade800),
                                        child: Image.asset(
                                          ImageConstanst.icCSV,
                                          color: Colors.blue,
                                        )),
                                    10.widthBox,
                                    Text(
                                      LocaleKeys.csvFile.tr,
                                      style: TextStyle(
                                          color: Helper.getTextColor(context),
                                          fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                              14.heightBox,
                              InkWell(
                                onTap: () {
                                  MasterPasswordDialog()
                                      .showMasterPasswordDialog(
                                          context: context,
                                          export: true,
                                          backupType: "DRIVE");
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      child: Image.asset(
                                        ImageConstanst.isDrive,
                                        color: Colors.blue,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade800),
                                      height: 38,
                                      width: 38,
                                    ),
                                    10.widthBox,
                                    Text(LocaleKeys.gDrive.tr,
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 15))
                                  ],
                                ),
                              ),
                              14.heightBox,
                              InkWell(
                                onTap: () {
                                  MasterPasswordDialog()
                                      .showMasterPasswordDialog(
                                          context: context,
                                          export: true,
                                          backupType: "DB");
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      child: Image.asset(ImageConstanst.isDb,
                                          color: Colors.blue),
                                      height: 38,
                                      width: 38,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade800),
                                    ),
                                    10.widthBox,
                                    Text(LocaleKeys.dbFile.tr,
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 15))
                                  ],
                                ),
                              ),
                              14.heightBox
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /*     InkWell(
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
                      ),*/
                20.heightBox,
                InkWell(
                  onTap: () {
                    MasterPasswordDialog().showMasterPasswordDialog(
                        context: context, export: false, backupType: "");
                    print("backup");
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
                              LocaleKeys.restore.tr,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Helper.getTextColor(context)),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 16,
                            ),
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

  void currencyBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return CurrencyBottomSheet(setData: _setDataFromBottomSheet);
      },
    );
  }

  Future<void> getCurrencyTypes() async {
    try {
      List<CurrencyCategory> currencyTypeList =
          await databaseHelper.currencyMethods();
      setState(() {
        currencyTypes = currencyTypeList;
      });
    } catch (e) {
      Helper.showToast(e.toString());
    }
  }

  Future<void> getLanguageTypes() async {
    try {
      List<LanguageCategory> languageTypesList =
          await databaseHelper.languageMethods();
      setState(() {
        languageTypes = languageTypesList;
      });
    } catch (e) {
      Helper.showToast(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.languageCode)
        .then((value) {
      if (value == "en") {
        language = 'English';
      } else if (value == "hi") {
        language = "Hindi";
      } else if (value == "gu") {
        language = "Gujarati";
      }
    });
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currencyCode)
        .then((value) {
      if (value != null) {
        cCode = value;
      }
    });
    getLanguageTypes();
    getCurrencyTypes();
  }

  void languageBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return LanguageBottomSheetContent();
      },
    );
  }

  void _setDataFromBottomSheet(String data) {
    setState(() {
      codeFromBottomSheet = data;
    });
  }
}
