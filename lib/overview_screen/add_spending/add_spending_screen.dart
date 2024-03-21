import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/overview_screen/add_spending/bloc/add_spending_event.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../db_models/category_model.dart';
import '../../db_models/income_category.dart';
import '../../db_models/income_sub_category.dart';
import '../../db_models/spending_sub_category.dart';
import '../../db_service/database_helper.dart';
import '../../utils/my_shared_preferences.dart';
import '../../utils/views/custom_text_form_field.dart';
import 'bloc/add_spending_bloc.dart';
import 'bloc/add_spending_state.dart';

class AddSpendingScreen extends StatefulWidget {
  String transactionName;
   AddSpendingScreen({super.key,required this.transactionName});

  @override
  State<AddSpendingScreen> createState() => _AddSpendingScreenState();
}

class _AddSpendingScreenState extends State<AddSpendingScreen> {
  AddSpendingBloc addSpendingBloc = AddSpendingBloc();
  final picker = ImagePicker();
  File? image1, image2, image3;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  int currPage = 1;
  bool isSkippedUser = false;
  String selectedValue = AppConstanst.spendingTransactionName;
  List<String> dropdownItems = [AppConstanst.spendingTransactionName, AppConstanst.incomeTransactionName];

  final List<String> amount = [
    "500",
    "1000",
    "1500",
    "2000",
    "5000",
  ];

  late DateTime currentDate;

  List<Category> selectedItemList = [];
  List<IncomeCategory> selectedIncomeItemList = [];

  List<Category> categories = [];
  List<SpendingSubCategory> spendingSubCategories = [];

  List<IncomeCategory> incomeCategories = [];
  List<IncomeSubCategory> incomeSubCategories = [];

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  String userEmail = '';

  Future<void> getSpendingCategory() async {
    try {
      List<Category> fetchedCategories = await databaseHelper.categorys();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (error) {
      setState(() {});
    }
  }

  Future<void> getSpendingSubCategory() async {
    try {
      List<SpendingSubCategory> fetchedSpendingSubCategories =
          await databaseHelper
              .getSpendingSubCategory(selectedItemList[0].id!.toInt());
      setState(() {
        spendingSubCategories = fetchedSpendingSubCategories;
      });
    } catch (error) {
      setState(() {});
    }
  }

  Future<void> getIncomeCategory() async {
    try {
      List<IncomeCategory> fetchedIncomeCategories =
          await databaseHelper.getIncomeCategory();
      setState(() {
        incomeCategories = fetchedIncomeCategories;
      });
    } catch (error) {
      setState(() {});
    }
  }

  Future<void> getIncomeSubCategory() async {
    try {
      List<IncomeSubCategory> fetchedIncomeSubCategories = await databaseHelper
          .getIncomeSubCategory(selectedIncomeItemList[0].id!.toInt());
      setState(() {
        incomeSubCategories = fetchedIncomeSubCategories;
      });
    } catch (error) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
      }
    });
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
      }
    });
    selectedValue = widget.transactionName;
    if(selectedValue == AppConstanst.spendingTransactionName) {
      getSpendingCategory();
    }else{
     getIncomeCategory();
    }
  }

  void _incrementDate() {
    setState(() {
      currentDate = currentDate.add(Duration(days: 1));
    });
  }

  void _decrementDate() {
    setState(() {
      currentDate = currentDate.subtract(Duration(days: 1));
    });
  }

  String formattedDate() {
    return DateFormat('dd/MM/yyyy').format(currentDate);
  }

  String formattedTime() {
    return DateFormat('HH:mm').format(currentDate);
  }

  int selectedSpendingSubIndex = -1;
  int selectedSpendingIndex = -1;
  int selectedIncomeSubIndex = -1;
  int selectedIncomeIndex = -1;

  createSpendingIncome(BuildContext context, int id, String email) async {
    await databaseHelper
        .insertTransactionData(
      TransactionModel(
          member_id: id,
          member_email: email,
          amount: int.parse(amountController.text),
          expense_cat_id: selectedSpendingIndex,
          sub_expense_cat_id: selectedSpendingSubIndex,
          income_cat_id: selectedIncomeIndex,
          sub_income_cat_id: selectedIncomeSubIndex,
          cat_name: selectedValue == AppConstanst.spendingTransactionName
              ? selectedSpendingSubIndex != -1
                  ? spendingSubCategories[selectedSpendingSubIndex].name
                  : categories[selectedSpendingIndex].name
              : selectedIncomeSubIndex != -1
                  ? incomeSubCategories[selectedIncomeSubIndex].name
                  : incomeCategories[selectedIncomeIndex].name,
          cat_color: selectedValue == AppConstanst.spendingTransactionName
              ? categories[selectedSpendingIndex].color
              : incomeCategories[selectedIncomeIndex].color,
          cat_icon: selectedValue == AppConstanst.spendingTransactionName
              ? categories[selectedSpendingIndex].icons
              : incomeCategories[selectedIncomeIndex].path,
          payment_method_id: AppConstanst.cashPaymentType,
          status: 1,
          transaction_date: '${formattedDate()} ${formattedTime()}',
          transaction_type: selectedValue == AppConstanst.spendingTransactionName
              ? AppConstanst.spendingTransaction
              : AppConstanst.incomeTransaction,
          description: descriptionController.text,
          currency_id: AppConstanst.rupeesCurrency,
          receipt_image1: image1?.path ?? "",
          receipt_image2: image2?.path ?? "",
          receipt_image3: image3?.path ?? "",
          created_at: DateTime.now().toString(),
          last_updated: DateTime.now().toString()),
    )
        .then((value) async {
      if (value != null) {
        // Helper.hideLoading(context);
        DateTime now = DateTime.now();
        String currentMonthName = DateFormat('MMMM').format(now);
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime parsedDate = format.parse(formattedDate());
        String transactionMonthName = DateFormat('MMMM').format(parsedDate);
        if(currentMonthName == transactionMonthName) {
            if (isSkippedUser) {
              if (selectedValue == AppConstanst.spendingTransactionName) {
                MySharedPreferences.instance
                    .getStringValuesSF(
                    SharedPreferencesKeys.skippedUserCurrentBalance)
                    .then((value) {
                  if (value != null) {
                    String updateBalance =
                    (int.parse(value) - int.parse(amountController.text))
                        .toString();
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentBalance,
                        updateBalance);
                  }
                });
              }else{
                MySharedPreferences.instance
                    .getStringValuesSF(
                    SharedPreferencesKeys.skippedUserCurrentIncome)
                    .then((value) {
                  if (value != null) {
                    String updateBalance =
                    (int.parse(value) + int.parse(amountController.text))
                        .toString();
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentIncome,
                        updateBalance);
                  }
                });
              }
            } else {
              await DatabaseHelper.instance
                  .getProfileData(userEmail)
                  .then((profileData) async {
                if (selectedValue == AppConstanst.spendingTransactionName) {
                  profileData.current_balance =
                      (int.parse(profileData.current_balance!) -
                          int.parse(amountController.text))
                          .toString();
                }else{
                  profileData.current_income =
                      (int.parse(profileData.current_income!) +
                          int.parse(amountController.text))
                          .toString();
                }
                await DatabaseHelper.instance.updateProfileData(profileData);
              });
            }

        }
        Helper.showToast(selectedValue == AppConstanst.spendingTransactionName
            ? "Spending created successfully"
            : "Income created successfully");
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddSpendingBloc, AddSpendingState>(
      bloc: addSpendingBloc,
      listener: (context, state) {},
      builder: (context, state) {
        addSpendingBloc.context = context;
        return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Helper.getBackgroundColor(context),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 16),
                    ),
                  ),
                  10.widthBox,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              color: const Color(0xff22435b),
                              borderRadius: BorderRadius.circular(25)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              dropdownElevation: 0,
                              buttonDecoration: const BoxDecoration(
                                  color: Colors.transparent),
                              dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xff22435b)),
                              items: dropdownItems
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(item,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white)),
                                        ),
                                      ))
                                  .toList(),
                              dropdownMaxHeight: 200,
                              offset: const Offset(0, -1),
                              value: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  var val = value as String;
                                  selectedValue = val;
                                  if (selectedValue == AppConstanst.spendingTransactionName) {
                                    getSpendingCategory();
                                  } else {
                                    getIncomeCategory();
                                  }
                                });
                              },
                              buttonPadding: EdgeInsets.zero,
                              buttonHeight: 40,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ),
                  ),
                  10.widthBox,
                  InkWell(
                    onTap: () async {
                      if (amountController.text.isEmpty ||
                          amountController.text == "0") {
                        Helper.showToast("Please add amount");
                      } else if (selectedValue == AppConstanst.spendingTransactionName
                          ? selectedSpendingIndex == -1
                          : selectedIncomeIndex == -1) {
                        Helper.showToast("Please select category");
                      } else if (selectedValue == AppConstanst.spendingTransactionName
                          ? (spendingSubCategories.isNotEmpty &&
                              selectedSpendingSubIndex == -1)
                          : (incomeSubCategories.isNotEmpty &&
                              selectedIncomeSubIndex == -1)) {
                        Helper.showToast("Please select sub category");
                      } else {
                        //   Helper.showLoading(context);
                        if (!isSkippedUser) {
                          await databaseHelper
                              .getProfileData(userEmail)
                              .then((value) async {
                            createSpendingIncome(
                                context, value.id!, value.email!);
                          });
                        } else {
                          createSpendingIncome(context, -1, "");
                        }
                      }
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: Helper.getBackgroundColor(context),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Helper.getCardColor(context)),
                        child: const Icon(
                          Icons.currency_exchange,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                      15.widthBox,
                      Expanded(
                          child: CustomBoxTextFormField(
                              controller: amountController,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5)),
                              keyboardType: TextInputType.number,
                              hintText: "0",
                              hintFontSize: 20,
                              hintColor: Colors.blue,
                              fillColor: Helper.getCardColor(context),
                              textAlign: TextAlign.end,
                              borderColor: Colors.transparent,
                              textStyle: const TextStyle(
                                  color: Colors.blue, fontSize: 20),
                              padding: 11,
                              horizontalPadding: 5,
                              validator: (value) {
                                return null;
                              })),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.2, horizontal: 5),
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            border: Border(
                              left: BorderSide(
                                color: Helper.getCardColor(context),
                              ),
                            ),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5))),
                        child: Row(
                          children: [
                            5.widthBox,
                            const Text("\u20B9",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blue)),
                            5.widthBox,
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 12,
                              color: Helper.getTextColor(context),
                            )
                          ],
                        ),
                      ),
                    ]),
                    10.heightBox,
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: amount.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (amountController.text.isNotEmpty) {
                                amountController.text =
                                    (int.parse(amountController.text) +
                                            int.parse(amount[index]))
                                        .toString();
                              } else {
                                amountController.text = amount[index];
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Text(
                                amount[index],
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 14),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return 10.widthBox;
                        },
                      ),
                    ),
                    20.heightBox,
                    selectedValue == AppConstanst.spendingTransactionName
                        ? Row(
                            children: [
                              Text(
                                "CATEGORY",
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 14),
                              ),
                              10.widthBox,
                              const Icon(
                                Icons.settings,
                                color: Colors.blue,
                                size: 18,
                              ),
                              if (selectedItemList.isNotEmpty)
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        spendingSubCategories = [];
                                        selectedSpendingSubIndex = -1;
                                        selectedSpendingIndex = -1;
                                        selectedItemList.clear();
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            selectedItemList[0].name.toString(),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                color: Helper.getTextColor(
                                                    context),
                                                fontSize: 14),
                                          ),
                                        ),
                                        5.widthBox,
                                        Icon(
                                          Icons.highlight_remove,
                                          color: Helper.getTextColor(context),
                                          size: 18,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              /*5.widthBox,
                              if (selectedItemList.isNotEmpty)
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        spendingSubCategories = [];
                                        selectedSpendingSubIndex = -1;
                                        selectedSpendingIndex = -1;
                                        selectedItemList.clear();
                                      });
                                    },
                                    child: const Icon(
                                      Icons.highlight_remove,
                                      color: Colors.white,
                                      size: 18,
                                    )),*/
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                "CATEGORY",
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 14),
                              ),
                              10.widthBox,
                              const Icon(
                                Icons.settings,
                                color: Colors.blue,
                                size: 18,
                              ),
                              if (selectedIncomeItemList.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    selectedIncomeItemList[0].name.toString(),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: Helper.getTextColor(context),
                                        fontSize: 14),
                                  ),
                                ),
                              5.widthBox,
                              if (selectedIncomeItemList.isNotEmpty)
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        incomeSubCategories = [];
                                        selectedIncomeSubIndex = -1;
                                        selectedIncomeIndex = -1;
                                        selectedIncomeItemList.clear();
                                      });
                                    },
                                    child: SizedBox(
                                      width: 50,
                                      child: Icon(
                                        Icons.highlight_remove,
                                        color: Helper.getTextColor(context),
                                        size: 18,
                                      ),
                                    )),
                            ],
                          ),
                    5.heightBox,
                    selectedValue == AppConstanst.spendingTransactionName
                        ? Stack(
                            children: [
                              GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 4.0,
                                  childAspectRatio: 4 / 4,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: spendingSubCategories.isEmpty
                                    ? categories.length
                                    : selectedItemList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Category item = spendingSubCategories.isEmpty
                                      ? categories[index]
                                      : selectedItemList[index];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedItemList = [];
                                        spendingSubCategories = [];
                                        selectedSpendingIndex = index;
                                        selectedItemList.add(categories[index]);
                                        getSpendingSubCategory();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: selectedSpendingIndex == index
                                              ? spendingSubCategories.isNotEmpty
                                                  ? Helper
                                                      .getCategoriesItemColors(
                                                          context)
                                                  : Colors.blue
                                              : Helper.getCategoriesItemColors(
                                                  context),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            'asset/images/${item.icons}.svg',
                                            color:
                                                selectedSpendingIndex == index
                                                    ? spendingSubCategories
                                                            .isNotEmpty
                                                        ? item.color
                                                        : Colors.white
                                                    : item.color,
                                            width: 28,
                                            height: 28,
                                          ),
                                          Expanded(
                                            child: Text(
                                              item.name.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (spendingSubCategories.isNotEmpty)
                                Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right:
                                        MediaQuery.of(context).size.width / 1.8,
                                    child: const VerticalDivider(
                                        color: Colors.blue, thickness: 3)),
                              Row(
                                children: [
                                  if (spendingSubCategories.isNotEmpty)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          4.8,
                                    ),
                                  if (spendingSubCategories.isNotEmpty)
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 4.0,
                                          mainAxisSpacing: 4.0,
                                          childAspectRatio: 3.5 / 1,
                                        ),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: spendingSubCategories.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          SpendingSubCategory item =
                                              spendingSubCategories[index];
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedSpendingSubIndex =
                                                    index;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 5),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color:
                                                      selectedSpendingSubIndex ==
                                                              index
                                                          ? Colors.blue
                                                          : Helper.getCardColor(
                                                              context),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.name!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: selectedSpendingSubIndex ==
                                                                  index
                                                              ? Colors.white
                                                              : Helper
                                                                  .getTextColor(
                                                                      context),
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              )
                            ],
                          )
                        : Stack(
                            children: [
                              GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 4.0,
                                  childAspectRatio: 4 / 4,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: incomeSubCategories.isEmpty
                                    ? incomeCategories.length
                                    : selectedIncomeItemList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  IncomeCategory item =
                                      incomeSubCategories.isEmpty
                                          ? incomeCategories[index]
                                          : selectedIncomeItemList[index];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedIncomeItemList = [];
                                        incomeSubCategories = [];
                                        selectedIncomeIndex = index;
                                        selectedIncomeItemList
                                            .add(incomeCategories[index]);
                                        getIncomeSubCategory();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: selectedIncomeIndex == index
                                              ? incomeSubCategories.isNotEmpty
                                                  ? Helper.getCardColor(context)
                                                  : Colors.blue
                                              : Helper.getCardColor(context),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            'asset/images/${item.path}.svg',
                                            color: selectedIncomeIndex == index
                                                ? incomeSubCategories.isNotEmpty
                                                    ? item.color
                                                    : Colors.white
                                                : item.color,
                                            width: 28,
                                            height: 28,
                                          ),
                                          Expanded(
                                            child: Text(
                                              item.name.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: selectedIncomeIndex ==
                                                          index
                                                      ? Colors.white
                                                      : Helper.getTextColor(context),
                                                  fontSize: 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (incomeSubCategories.isNotEmpty)
                                Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right:
                                        MediaQuery.of(context).size.width / 1.8,
                                    child: const VerticalDivider(
                                        color: Colors.blue, thickness: 3)),
                              Row(
                                children: [
                                  if (incomeSubCategories.isNotEmpty)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          4.8,
                                    ),
                                  if (incomeSubCategories.isNotEmpty)
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 4.0,
                                          mainAxisSpacing: 4.0,
                                          childAspectRatio: 3.5 / 1,
                                        ),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: incomeSubCategories.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          IncomeSubCategory item =
                                              incomeSubCategories[index];
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedIncomeSubIndex = index;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 5),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color:
                                                      selectedIncomeSubIndex ==
                                                              index
                                                          ? Colors.blue
                                                          : Helper.getCardColor(
                                                              context),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.name!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Helper
                                                              .getTextColor(
                                                                  context),
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                    20.heightBox,
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Helper.getCardColor(context)),
                        child: const Icon(
                          Icons.calendar_month_sharp,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                      15.widthBox,
                      InkWell(
                        onTap: () {
                          _decrementDate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: const Icon(
                            Icons.calendar_month_sharp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      5.widthBox,
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formattedDate(),
                                style: TextStyle(
                                    color: Helper.getTextColor(context)),
                              ),
                              5.widthBox,
                              Text(
                                formattedTime(),
                                style: TextStyle(
                                    color: Helper.getTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      5.widthBox,
                      InkWell(
                        onTap: () {
                          DateFormat format = DateFormat("dd/MM/yyyy");
                          String formattedDateTime = DateFormat('dd/MM/yyyy').format(DateTime.now());

                          if(format.parse(formattedDateTime).isAfter(format.parse(formattedDate()))) {
                            _incrementDate();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: const Icon(
                            Icons.calendar_month_sharp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ]),
                    10.heightBox,
                    Stack(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  currPage = 1;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "DETAILS",
                                    style: TextStyle(
                                        color: currPage == 1
                                            ? Colors.blue
                                            : Colors.white,
                                        fontSize: 14),
                                  ),
                                  currPage == 1
                                      ? Container(
                                          width: 55,
                                          height: 2,
                                          color: Colors.blue,
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: -8,
                          left: 0,
                          right: 0,
                          child: Divider(
                            thickness: 2,
                            color: Helper.getCardColor(context),
                          ),
                        ),
                      ],
                    ),
                    10.heightBox,
                    currPage == 1 ? _detailsView(addSpendingBloc) : 0.heightBox,
                  ],
                ),
              ),
            ));
      },
    );
  }

  Widget _detailsView(AddSpendingBloc addSpendingBloc) {
    return BlocConsumer<AddSpendingBloc, AddSpendingState>(
        bloc: addSpendingBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            children: [
              Row(children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Helper.getCardColor(context)),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
                15.widthBox,
                Expanded(
                    child: CustomBoxTextFormField(
                        controller: descriptionController,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        keyboardType: TextInputType.text,
                        hintText: "Enter description",
                        fillColor: Helper.getCardColor(context),
                        borderColor: Colors.transparent,
                        padding: 11,
                        horizontalPadding: 5,
                        textStyle:
                            TextStyle(color: Helper.getTextColor(context)),
                        validator: (value) {
                          return null;
                        })),
              ]),
              10.heightBox,
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Helper.getCardColor(context)),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
                15.widthBox,
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wallet,
                        color: Colors.white,
                      ),
                      5.heightBox,
                      const Text(
                        "Cash",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                )
              ]),
              10.heightBox,
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Helper.getCardColor(context)),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
                15.widthBox,
                InkWell(
                  onTap: () {
                    FocusScope.of(addSpendingBloc.context)
                        .requestFocus(FocusNode());
                    _storagePermission(1);
                  },
                  child: state is SelectedImageState
                      ? image1 == null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.blue,
                              ),
                            )
                          : Image.file(
                              image1!,
                              fit: BoxFit.cover,
                              height: 50,
                              width: 50,
                            )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.blue,
                          ),
                        ),
                ),
                10.widthBox,
                InkWell(
                    onTap: () {
                      FocusScope.of(addSpendingBloc.context)
                          .requestFocus(FocusNode());
                      _storagePermission(2);
                    },
                    child: state is SelectedImageState
                        ? image2 == null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.blue,
                                ),
                              )
                            : Image.file(
                                image2!,
                                fit: BoxFit.cover,
                                height: 50,
                                width: 50,
                              )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.blue,
                            ),
                          )),
                10.widthBox,
                InkWell(
                    onTap: () {
                      FocusScope.of(addSpendingBloc.context)
                          .requestFocus(FocusNode());
                      _storagePermission(3);
                    },
                    child: state is SelectedImageState
                        ? image3 == null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.blue,
                                ),
                              )
                            : Image.file(
                                image3!,
                                fit: BoxFit.cover,
                                height: 50,
                                width: 50,
                              )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.blue,
                            ),
                          )),
              ]),
            ],
          );
        });
  }

  _storagePermission(int position) async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final androidVersion =
        int.parse(deviceInfo.version.release.split('.').first);
    if (androidVersion >= 13) {
      _shopImagePickerDialog(position);
    } else {
      _requestPermission(position);
    }

    return Colors.grey;
  }

  /// Function: request for camera access permission
  /// @return widget
  /// */
  _requestPermission(int position) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    PermissionStatus? info = statuses[Permission.storage];
    switch (info) {
      case PermissionStatus.denied:
        break;
      case PermissionStatus.granted:
        _shopImagePickerDialog(position);
        break;
      default:
        return Colors.grey;
    }
  }

  /// Function: image pickee dialog view
  /// @return widget
  /// */
  Future _shopImagePickerDialog(int position) async {
    await showDialog(
      context: addSpendingBloc.context,
      builder: (cont) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          insetPadding: const EdgeInsets.all(20),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Option',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Helper.getTextColor(addSpendingBloc.context)),
                    ),
                    IconButton(
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // the '2023' part
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.pop(addSpendingBloc.context);
                        },
                        icon: const Icon(Icons.close, color: Colors.grey))
                  ],
                ),
                15.heightBox,
                InkWell(
                  onTap: () {
                    Navigator.pop(addSpendingBloc.context);
                    _getImage(ImageSource.camera, position);
                  },
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      'Camera',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Helper.getTextColor(addSpendingBloc.context)),
                    ),
                  ),
                ),
                10.heightBox,
                InkWell(
                  onTap: () {
                    Navigator.pop(addSpendingBloc.context);
                    _getImage(ImageSource.gallery, position);
                  },
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      'Gallery',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Helper.getTextColor(addSpendingBloc.context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Function: get image from gallery
  /// @return void
  /// */
  void _getImage(ImageSource imageSource, int position) async {
    try {
      XFile? imageFile = await picker.pickImage(source: imageSource);
      if (imageFile == null) return;
      File tmpFile = File(imageFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(imageFile.path);
      tmpFile = await tmpFile.copy('${appDir.path}/$fileName');
      if (position == 1) {
        image1 = tmpFile;
      } else if (position == 2) {
        image2 = tmpFile;
      } else {
        image3 = tmpFile;
      }
      addSpendingBloc.add(OnImageSelectedEvent(
          context: addSpendingBloc.context,
          image1: image1,
          image2: image2,
          image3: image3));
    } catch (e) {
      debugPrint('image-picker-error ${e.toString()}');
    }
  }
}
