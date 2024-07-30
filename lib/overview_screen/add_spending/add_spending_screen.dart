import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/db_models/accounts_model.dart';
import 'package:expense_manager/db_models/payment_method_model.dart';
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../db_models/expense_category_model.dart';
import '../../db_models/expense_sub_category.dart';
import '../../db_models/income_category.dart';
import '../../db_models/income_sub_category.dart';
import '../../db_models/profile_model.dart';
import '../../db_service/database_helper.dart';
import '../../utils/views/custom_text_form_field.dart';

class AddSpendingScreen extends StatefulWidget {
  String transactionName;

  AddSpendingScreen({super.key, required this.transactionName});

  @override
  State<AddSpendingScreen> createState() => _AddSpendingScreenState();
}

class _AddSpendingScreenState extends State<AddSpendingScreen> {
  final picker = ImagePicker();
  File? image1, image2, image3;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  int currPage = 1;
  bool isSkippedUser = false;
  String selectedValue = AppConstanst.spendingTransactionName;
  List<String> dropdownItems = [
    AppConstanst.spendingTransactionName,
    AppConstanst.incomeTransactionName
  ];

  final List<String> amount = [
    "500",
    "1000",
    "1500",
    "2000",
    "5000",
  ];

  DateTime selectedDate = DateTime.now();

  List<ExpenseCategory> selectedItemList = [];
  List<IncomeCategory> selectedIncomeItemList = [];

  List<ExpenseCategory> categories = [];
  List<ExpenseSubCategory> spendingSubCategories = [];

  List<IncomeCategory> incomeCategories = [];
  List<IncomeSubCategory> incomeSubCategories = [];
  List<PaymentMethod> paymentMethods = [];

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  String currentUserKey = '';
  String currentAccountKey = '';

  Color forwardIconColor = Colors.grey; // Initialize color to grey

  int selectedSpendingSubIndex = -1;

  int selectedSpendingIndex = -1;

  int selectedIncomeSubIndex = -1;

  int selectedIncomeIndex = -1;

  int selectedPaymentMethodIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                  LocaleKeys.cancel.tr,
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
                          selectedItemBuilder: (BuildContext context) {
                            return dropdownItems.map((item){
                              return Align(
                                alignment: Alignment.center,
                                child: Text(
                                  item,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white, // Selected item text color
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          items: dropdownItems
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(item,
                                          textAlign: TextAlign.center,
                                          style:  TextStyle(
                                              fontSize: 14,
                                              color: Helper.getTextColor(context))),
                                    ),
                                  ))
                              .toList(),
                          dropdownStyleData: DropdownStyleData(

                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius: BorderRadius.circular(8))),
                          value: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              var val = value as String;
                              selectedValue = val;
                              if (selectedValue ==
                                  AppConstanst.spendingTransactionName) {
                                getSpendingCategory();
                              } else {
                                getIncomeCategory();
                              }
                            });
                          },
                          isExpanded: true,
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
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
                    Helper.showToast(LocaleKeys.addAmount.tr);
                  } else if (selectedValue ==
                          AppConstanst.spendingTransactionName
                      ? selectedSpendingIndex == -1
                      : selectedIncomeIndex == -1) {
                    Helper.showToast(LocaleKeys.addCategory.tr);
                  } else if (selectedValue ==
                          AppConstanst.spendingTransactionName
                      ? (spendingSubCategories.isNotEmpty &&
                          selectedSpendingSubIndex == -1)
                      : (incomeSubCategories.isNotEmpty &&
                          selectedIncomeSubIndex == -1)) {
                    Helper.showToast(LocaleKeys.addSubCategory.tr);
                  } else {
                    //   Helper.showLoading(context);
                    if (!isSkippedUser) {
                      print("USER NOT SKIPPED $isSkippedUser");
                      /* await databaseHelper
                          .getProfileData(userEmail)
                          .then((value) async {*/
                      createSpendingIncome(context);
                      // });
                    } else {
                      print("USER SKIPPED $isSkippedUser");
                      createSpendingIncome(context);
                    }
                  }
                },
                child: Text(
                  LocaleKeys.done.tr,
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
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
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
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(7),
                          ],
                          decoration: const InputDecoration(
                            counter: null
                          ),
                          hintFontSize: 20,
                          hintColor: Colors.blue,
                          fillColor: Helper.getCardColor(context),
                          textAlign: TextAlign.end,
                          borderColor: Colors.transparent,
                          textStyle:
                              const TextStyle(color: Colors.blue, fontSize: 20),
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
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5))),
                    child: Row(
                      children: [
                        5.widthBox,
                        Text("${AppConstanst.currencySymbol}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.blue)),
                        5.widthBox,
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
                                  const BorderRadius.all(Radius.circular(5))),
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
                            LocaleKeys.category.tr,
                            style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 14),
                          ),
                          10.widthBox,
                          SvgPicture.asset(
                            'asset/images/ic_categories.svg',
                            color: Colors.blue,
                            height: 18,
                            width: 18,
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
                                            color: Helper.getTextColor(context),
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
                            LocaleKeys.category.tr,
                            style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 14),
                          ),
                          10.widthBox,
                          SvgPicture.asset(
                            'asset/images/ic_categories.svg',
                            color: Colors.blue,
                            height: 18,
                            width: 18,
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
                              ExpenseCategory item =
                                  spendingSubCategories.isEmpty
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
                                  height: 16,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: selectedSpendingIndex == index
                                          ? spendingSubCategories.isNotEmpty
                                              ? Helper.getCategoriesItemColors(
                                                  context)
                                              : Colors.blue
                                          : Helper.getCategoriesItemColors(
                                              context),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5))),
                                  child: Column(
                                    children: [
                                      5.heightBox,
                                      SvgPicture.asset(
                                        'asset/images/${item.icons}.svg',
                                        color: selectedSpendingIndex == index
                                            ? spendingSubCategories.isNotEmpty
                                                ? item.color
                                                : Colors.white
                                            : item.color,
                                        width: 24,
                                        height: 24,
                                      ),
                                      5.heightBox,
                                      Expanded(
                                        child: Text(
                                          item.name.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color:
                                                  Helper.getTextColor(context),
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
                                right: MediaQuery.of(context).size.width / 1.8,
                                child: const VerticalDivider(
                                    color: Colors.blue, thickness: 3)),
                          Row(
                            children: [
                              if (spendingSubCategories.isNotEmpty)
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 4.8,
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
                                      ExpenseSubCategory item =
                                          spendingSubCategories[index];
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedSpendingSubIndex = index;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: selectedSpendingSubIndex ==
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
                                                      color:
                                                          selectedSpendingSubIndex ==
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
                              IncomeCategory item = incomeSubCategories.isEmpty
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
                                      5.heightBox,
                                      SvgPicture.asset(
                                        'asset/images/${item.path}.svg',
                                        color: selectedIncomeIndex == index
                                            ? incomeSubCategories.isNotEmpty
                                                ? item.color
                                                : Colors.white
                                            : item.color,
                                        width: 24,
                                        height: 24,
                                      ),
                                      5.heightBox,
                                      Expanded(
                                        child: Text(
                                          item.name.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color:
                                                  selectedIncomeIndex == index
                                                      ? Colors.white
                                                      : Helper.getTextColor(
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
                          if (incomeSubCategories.isNotEmpty)
                            Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: MediaQuery.of(context).size.width / 1.8,
                                child: const VerticalDivider(
                                    color: Colors.blue, thickness: 3)),
                          Row(
                            children: [
                              if (incomeSubCategories.isNotEmpty)
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 4.8,
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: selectedIncomeSubIndex ==
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
                                                      color:
                                                          Helper.getTextColor(
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
                              const BorderRadius.all(Radius.circular(5))),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  5.widthBox,
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(

                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.blue,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.blue,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Colors.blue, // button text color
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now());
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                            forwardIconColor =
                                pickedDate.isBefore(DateTime.now())
                                    ? Colors.blue
                                    : Colors.grey;
                          });
                        } else if (pickedDate != null &&
                            pickedDate == DateTime.now()) {
                          // If user selects the current date, set forward icon color to grey
                          setState(() {
                            forwardIconColor = Colors.grey;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formattedDate(),
                              style: TextStyle(
                                  color: Helper.getTextColor(context)),
                            ),
                            // 5.widthBox,
                            // Text(
                            //   formattedTime(),
                            //   style: TextStyle(
                            //       color: Helper.getTextColor(context)),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  5.widthBox,
                  InkWell(
                    onTap: () {
                      DateFormat format = DateFormat("dd/MM/yyyy");
                      String formattedDateTime =
                          DateFormat('dd/MM/yyyy').format(DateTime.now());
                      if (format
                          .parse(formattedDateTime)
                          .isAfter(format.parse(formattedDate()))) {
                        _incrementDate();
                      } else {
                        // If the selected date is the current date, set forward icon color to grey
                        setState(() {
                          forwardIconColor = Colors.grey;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Helper.getCardColor(context),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: forwardIconColor,
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
                                LocaleKeys.details.tr,
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
                currPage == 1 ? _detailsView(context) : 0.heightBox,
              ],
            ),
          ),
        ));
  }

  createSpendingIncome(BuildContext context) async {
    TransactionModel transactionModel = TransactionModel(
        key: "",
        // member_id: id,
        member_key: currentUserKey,
        account_key: currentAccountKey,
        amount: int.parse(amountController.text),
        expense_cat_id: selectedSpendingIndex != -1
            ? categories[selectedSpendingIndex].id
            : -1,
        sub_expense_cat_id: selectedSpendingSubIndex != -1
            ? spendingSubCategories[selectedSpendingSubIndex].id
            : -1,
        income_cat_id: selectedValue == AppConstanst.incomeTransactionName
            ? incomeCategories[selectedIncomeIndex].id
            : -1,
        sub_income_cat_id: selectedValue == AppConstanst.incomeTransactionName
            ? selectedIncomeSubIndex != -1
                ? incomeSubCategories[selectedIncomeSubIndex].id
                : -1
            : -1,
       /* cat_name: selectedValue == AppConstanst.spendingTransactionName
            ? selectedSpendingSubIndex != -1
                ? spendingSubCategories[selectedSpendingSubIndex].name
                : categories[selectedSpendingIndex].name
            : selectedIncomeSubIndex != -1
                ? incomeSubCategories[selectedIncomeSubIndex].name
                : incomeCategories[selectedIncomeIndex].name,*/
        cat_type: selectedValue == AppConstanst.spendingTransactionName
            ? selectedSpendingSubIndex != -1
                ? AppConstanst.subCategory
                : AppConstanst.mainCategory
            : selectedIncomeSubIndex != -1
                ? AppConstanst.subCategory
                : AppConstanst.mainCategory,
    /*    cat_color: selectedValue == AppConstanst.spendingTransactionName
            ? categories[selectedSpendingIndex].color
            : incomeCategories[selectedIncomeIndex].color,
        cat_icon: selectedValue == AppConstanst.spendingTransactionName
            ? categories[selectedSpendingIndex].icons
            : incomeCategories[selectedIncomeIndex].path,*/
        payment_method_id: paymentMethods[selectedPaymentMethodIndex].id,
        // payment_method_name: paymentMethods[selectedPaymentMethodIndex].name,
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
        last_updated: DateTime.now().toString());
    await databaseHelper
        .insertTransactionData(
            transactionModel, currentUserKey, currentAccountKey, isSkippedUser)
        .then((value) async {
      if (value != null) {
        // Helper.hideLoading(context);
        DateTime now = DateTime.now();
        String currentMonthName = DateFormat('MMMM').format(now);
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime parsedDate = format.parse(formattedDate());
        String transactionMonthName = DateFormat('MMMM').format(parsedDate);
        if (currentMonthName == transactionMonthName) {
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
            } else {
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
            final reference = FirebaseDatabase.instance
                .reference()
                .child(accounts_table)
                .child(currentUserKey)
                .orderByChild(AccountTableFields.key)
                .equalTo(currentAccountKey);

            reference.once().then((event) {
              DataSnapshot dataSnapshot = event.snapshot;
              if (event.snapshot.exists) {
                Map<dynamic, dynamic> values =
                    dataSnapshot.value as Map<dynamic, dynamic>;
                values.forEach((key, value) async {
                  var accountsModel = AccountsModel.fromMap(value);
                  if (selectedValue == AppConstanst.spendingTransactionName) {
                    accountsModel.balance =
                        (int.parse(accountsModel.balance!) -
                                int.parse(amountController.text))
                            .toString();
                  } else {
                    accountsModel.income =
                        (int.parse(accountsModel.income!) +
                                int.parse(amountController.text))
                            .toString();
                  }
                  await DatabaseHelper.instance.updateAccountData(accountsModel);
                });
              }
            });
          }
        }
        Helper.showToast(selectedValue == AppConstanst.spendingTransactionName
            ? LocaleKeys.spendingSuccessfully.tr
            : LocaleKeys.incomeSuccessfully.tr);
        Navigator.of(context).pop(true);
      }
    });
  }

  String formattedDate() {
    return DateFormat('dd/MM/yyyy').format(selectedDate);
  }

  String formattedTime() {
    return DateFormat('HH:mm').format(selectedDate);
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

  Future<void> getPaymentMethods() async {
    try {
      List<PaymentMethod> paymentMethodList =
          await databaseHelper.paymentMethods();
      setState(() {
        paymentMethods = paymentMethodList;
      });
    } catch (error) {
      setState(() {});
    }
  }

  Future<void> getSpendingCategory() async {
    try {
      List<ExpenseCategory> fetchedCategories =
          await databaseHelper.categorys();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (error) {
      setState(() {});
    }
  }

  Future<void> getSpendingSubCategory() async {
    try {
      List<ExpenseSubCategory> fetchedSpendingSubCategories =
          await databaseHelper
              .getSpendingSubCategory(selectedItemList[0].id!.toInt());
      setState(() {
        spendingSubCategories = fetchedSpendingSubCategories;
      });
    } catch (error) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currentUserKey)
        .then((value) {
      if (value != null) {
        currentUserKey = value;
        MySharedPreferences.instance
            .getStringValuesSF(SharedPreferencesKeys.currentAccountKey)
            .then((value) {
          if (value != null) {
            currentAccountKey = value;
          }
        });
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
    if (selectedValue == AppConstanst.spendingTransactionName) {
      getSpendingCategory();
    } else {
      getIncomeCategory();
    }
    getPaymentMethods();
  }

  void _decrementDate() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      forwardIconColor =
          selectedDate.isBefore(DateTime.now()) ? Colors.blue : Colors.grey;
    });
  }

  Widget _detailsView(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Helper.getCardColor(context)),
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
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  keyboardType: TextInputType.text,
                  hintText: LocaleKeys.enterDescription.tr,
                  fillColor: Helper.getCardColor(context),
                  borderColor: Colors.transparent,
                  padding: 11,
                  decoration: InputDecoration(
                    counterText: ""
                  ),
                  horizontalPadding: 5,
                  textStyle: TextStyle(color: Helper.getTextColor(context)),
                  validator: (value) {
                    return null;
                  })),
        ]),
        10.heightBox,
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Helper.getCardColor(context)),
            child: const Icon(
              Icons.menu,
              color: Colors.blue,
              size: 16,
            ),
          ),
          15.widthBox,
          SizedBox(
            height: 60,
            child: ListView.separated(
              physics: const ScrollPhysics(),
              itemCount: paymentMethods.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedPaymentMethodIndex = index;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: selectedPaymentMethodIndex == index
                            ? Colors.blue
                            : Helper.getCategoriesItemColors(context),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'asset/images/${paymentMethods[index].icon}.svg',
                          color: selectedPaymentMethodIndex == index
                              ? Colors.white
                              : Colors.blue,
                          width: 28,
                          height: 28,
                        ),
                        5.heightBox,
                        Text(
                          paymentMethods[index].name!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return 10.widthBox;
              },
            ),
          ),
        ]),
        10.heightBox,
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Helper.getCardColor(context)),
            child: const Icon(
              Icons.menu,
              color: Colors.blue,
              size: 16,
            ),
          ),
          15.widthBox,
          Stack(
            children: [
              // Image or Camera Icon
              image1 != null
                  ? InkWell(
                      onTap: () {
                        _showImage(context, image1!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        // Set the border radius here
                        child: Image.file(
                          image1!,
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _storagePermission(context, 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.blue,
                        ),
                      )),

              // Close Icon
              if (image1 != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        image1 = null; // Remove the image
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        // Change color to indicate wrong type
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          10.widthBox,
          Stack(
            children: [
              // Image or Camera Icon
              image2 != null
                  ? InkWell(
                      onTap: () {
                        _showImage(context, image2!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        // Set the border radius here
                        child: Image.file(
                          image2!,
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                      ))
                  : InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _storagePermission(context, 2);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.blue,
                        ),
                      )),

              // Close Icon
              if (image2 != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        image2 = null; // Remove the image
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        // Change color to indicate wrong type
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          10.widthBox,
          Stack(
            children: [
              // Image or Camera Icon
              image3 != null
                  ? InkWell(
                      onTap: () {
                        _showImage(context, image3!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        // Set the border radius here
                        child: Image.file(
                          image3!,
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _storagePermission(context, 3);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.blue,
                        ),
                      )),
              // Close Icon
              if (image3 != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        image3 = null; // Remove the image
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        // Change color to indicate wrong type
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ]),
      ],
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
      final appDir = await getExternalStorageDirectory();
      final fileName = basename(imageFile.path);
      tmpFile = await tmpFile.copy('/storage/emulated/0/Download/$fileName');
      if (position == 1) {
        image1 = tmpFile;
      } else if (position == 2) {
        image2 = tmpFile;
      } else {
        image3 = tmpFile;
      }
      setState(() {});
    } catch (e) {
      debugPrint('image-picker-error ${e.toString()}');
    }
  }

  void _incrementDate() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      forwardIconColor =
          selectedDate.isBefore(DateTime.now()) ? Colors.blue : Colors.grey;
    });
  }

  /// Function: request for camera access permission
  /// @return widget
  /// */
  _requestPermission(BuildContext context, int position) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    PermissionStatus? info = statuses[Permission.storage];
    switch (info) {
      case PermissionStatus.denied:
        break;
      case PermissionStatus.granted:
        _shopImagePickerDialog(context, position);
        break;
      default:
        return Colors.grey;
    }
  }

  /// Function: image pickee dialog view
  /// @return widget
  /// */
  Future _shopImagePickerDialog(BuildContext context, int position) async {
    await showDialog(
      context: context,
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
                      LocaleKeys.chooseOption.tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Helper.getTextColor(context)),
                    ),
                    IconButton(
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // the '2023' part
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.grey))
                  ],
                ),
                15.heightBox,
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera, position);
                  },
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      LocaleKeys.camera.tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Helper.getTextColor(context)),
                    ),
                  ),
                ),
                10.heightBox,
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery, position);
                  },
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      LocaleKeys.gallery.tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Helper.getTextColor(context)),
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

  void _showImage(BuildContext context, File image) async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            buttonPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  style: const ButtonStyle(
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, // the '2023' part
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  constraints: const BoxConstraints(),
                ),
                5.heightBox,
                Center(
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        image,
                        frameBuilder: (BuildContext context, Widget child,
                            int? frame, bool wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.blue,
                              )),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                10.heightBox,
              ],
            )));
  }

  _storagePermission(BuildContext context, int position) async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final androidVersion =
        int.parse(deviceInfo.version.release.split('.').first);
    if (androidVersion >= 13) {
      _shopImagePickerDialog(context, position);
    } else {
      _requestPermission(context, position);
    }

    return Colors.grey;
  }
}
