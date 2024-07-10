import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/statistics/search/CommonCategoryModel.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../db_models/accounts_model.dart';
import '../../db_models/profile_model.dart';
import '../../db_models/transaction_model.dart';
import '../../db_models/transaction_new_model.dart';
import '../../statistics/statistics_screen.dart';
import '../../utils/views/custom_text_form_field.dart';
import '../add_spending/DateWiseTransactionModel.dart';
import '../edit_spending/edit_spending_screen.dart';

class SpendingDetailScreen extends StatefulWidget {
  const SpendingDetailScreen({super.key});

  @override
  State<SpendingDetailScreen> createState() => _SpendingDetailScreenState();
}

class _SpendingDetailScreenState extends State<SpendingDetailScreen> {
  String userEmail = "";
  String currentUserEmail = "";

  String currentUserKey = "";
  String currentAccountKey = "";
  int userAccess = AppConstanst.viewOnlyAccess;
  bool isSkippedUser = false;
  final databaseHelper = DatabaseHelper();
  List<DateWiseTransactionModel> dateWiseTransaction = [];
  List<DateWiseTransactionModel> originalDateWiseTransaction = [];
  int currentBalance = 0;
  int actualBudget = 0;
  int totalMonthlySpentAmount = 0;
  double spendingPercentage = 0;
  String date = '';
  List<CommonCategoryModel> categoryList = [];
  TextEditingController searchController = TextEditingController();
  List<MonthData> monthList = [
    MonthData(text: 'January'),
    MonthData(text: 'February'),
    MonthData(text: 'March'),
    MonthData(text: 'April'),
    MonthData(text: 'May'),
    MonthData(text: 'June'),
    MonthData(text: 'July'),
    MonthData(text: 'August'),
    MonthData(text: 'September'),
    MonthData(text: 'October'),
    MonthData(text: 'November'),
    MonthData(text: 'December'),
  ];
  List<MonthData> selectedMonths = [];
  String selectedCategory = "";
  int selectedCategoryIndex = -1;
  String showYear = LocaleKeys.selectYear.tr;
  String showMonth = LocaleKeys.selectMonth.tr;
  DateTime _selectedYear = DateTime.now();
  bool isFilterCleared = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Helper.getBackgroundColor(context),
          title: Row(
            children: [
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Helper.getTextColor(context),
                    size: 20,
                  )),
              10.widthBox,
              Text(date,
                  style: TextStyle(
                    fontSize: 22,
                    color: Helper.getTextColor(context),
                  )),
              Text(" /${AppConstanst.currencySymbol}$actualBudget",
                  style: TextStyle(
                    fontSize: 16,
                    color: Helper.getTextColor(context),
                  )),
            ],
          ),
          actions: [
            InkWell(
              onTap: () {
                showModalBottomSheet<void>(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return WillPopScope(
                            onWillPop: () async {
                              return true;
                            },
                            child: Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: _bottomSheetView(setState)));
                      });
                    });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Helper.getCardColor(context)),
                child: Icon(
                  Icons.filter_alt_rounded,
                  color: Helper.getTextColor(context),
                  size: 20,
                ),
              ),
            ),
            10.widthBox,
          ],
        ),
        body: Container(
          color: Helper.getBackgroundColor(context),
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                      color: Helper.getCardColor(context),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircularPercentIndicator(
                        radius: 25.0,
                        lineWidth: 5.0,
                        percent: spendingPercentage / 100,
                        center: Text(
                          "${spendingPercentage.toPrecision(2)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        progressColor: Colors.blue,
                        backgroundColor: Colors.yellow,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.blue),
                              ),
                              5.widthBox,
                              Text(
                                LocaleKeys.spent.tr,
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          Text(
                            "${AppConstanst.currencySymbol}$totalMonthlySpentAmount",
                            style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.yellow),
                              ),
                              5.widthBox,
                              Text(
                                LocaleKeys.remaining.tr,
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          Text(
                            "${AppConstanst.currencySymbol}${actualBudget - totalMonthlySpentAmount}",
                            style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                20.heightBox,
                CustomBoxTextFormField(
                    controller: searchController,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    keyboardType: TextInputType.text,
                    hintText: LocaleKeys.notesCategories.tr,
                    fillColor: Helper.getCardColor(context),
                    borderColor: Colors.transparent,
                    padding: 10,
                    decoration: InputDecoration(
                        counterText: ""
                    ),
                    textStyle: TextStyle(color: Helper.getTextColor(context)),
                    horizontalPadding: 5,
                    suffixIcon: searchController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              searchController.clear();
                              if (showYear != LocaleKeys.selectYear.tr &&
                                  selectedMonths.isNotEmpty) {
                                getFilteredData("");
                              } else {
                                getTransactions("");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.close,
                                size: 22,
                                color: Helper.getTextColor(context),
                              ),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.search,
                              size: 22,
                              color: Colors.grey,
                            ),
                          ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (showYear != LocaleKeys.selectYear.tr &&
                            selectedMonths.isNotEmpty) {
                          getFilteredData(value);
                        } else {
                          getTransactions(value);
                        }
                      } else {
                        dateWiseTransaction = originalDateWiseTransaction;
                        if (showYear != LocaleKeys.selectYear.tr &&
                            selectedMonths.isNotEmpty) {
                          getFilteredData("");
                        } else {
                          getTransactions("");
                        }
                      }
                    },
                    validator: (value) {
                      return null;
                    }),
                if (dateWiseTransaction.isNotEmpty) 20.heightBox,
                if (dateWiseTransaction.isNotEmpty)
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: dateWiseTransaction.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${dateWiseTransaction[index].transactionDay}, ${dateWiseTransaction[index].transactionDate}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                Text(
                                  "-${AppConstanst.currencySymbol}${dateWiseTransaction[index].transactionTotal}",
                                  style: const TextStyle(
                                      color: Colors.pink, fontSize: 14),
                                ),
                              ],
                            ),
                            15.heightBox,
                            if (dateWiseTransaction[index]
                                .transactions!
                                .isNotEmpty)
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: dateWiseTransaction[index]
                                    .transactions!
                                    .length,
                                itemBuilder: (context, index1) {
                                  return InkWell(
                                    onTap: () {
                                      bool currentEmail = userEmail.isNotEmpty
                                          ? userEmail == currentUserEmail
                                              ? true
                                              : userAccess ==
                                                      AppConstanst.editAccess
                                                  ? true
                                                  : false
                                          : true;
                                      if (currentEmail) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditSpendingScreen(
                                                    transactionModel:
                                                    TransactionModel.fromOtherModel(dateWiseTransaction[
                                                                    index]
                                                                .transactions![
                                                            index1]),
                                                  )),
                                        )
                                            .then((value) {
                                          if (value != null) {
                                            if (value) {
                                              getTransactions("");
                                            }
                                          }
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Helper.getCardColor(context),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: SvgPicture.asset(
                                              'asset/images/${dateWiseTransaction[index].transactions![index1].cat_icon}.svg',
                                              color: dateWiseTransaction[index]
                                                  .transactions![index1]
                                                  .cat_color,
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                          15.widthBox,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dateWiseTransaction[index]
                                                      .transactions![index1]
                                                      .cat_name!,
                                                  style: TextStyle(
                                                      color:
                                                          Helper.getTextColor(
                                                              context),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  dateWiseTransaction[index]
                                                      .transactions![index1]
                                                      .description!,
                                                  style: TextStyle(
                                                    color: Helper.getTextColor(
                                                        context),
                                                    fontSize: 14,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "-${AppConstanst.currencySymbol}${dateWiseTransaction[index].transactions![index1].amount!}",
                                                style: TextStyle(
                                                    color: Helper.getTextColor(
                                                        context),
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                dateWiseTransaction[index]
                                                            .transactions![
                                                                index1]
                                                            .payment_method_id ==
                                                        AppConstanst
                                                            .cashPaymentType
                                                    ? 'Cash'
                                                    : '',
                                                style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return 10.heightBox;
                                },
                              ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return 10.heightBox;
                      },
                    ),
                  ),
                if (dateWiseTransaction.isEmpty) 20.heightBox,
                if (dateWiseTransaction.isEmpty)
                  Container(
                      decoration: BoxDecoration(
                          color: Helper.getCardColor(context),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        children: [
                          20.heightBox,
                          Icon(
                            Icons.account_balance_wallet,
                            color: Helper.getTextColor(context),
                            size: 80,
                          ),
                          10.heightBox,
                          Text(
                            LocaleKeys.dontHaveExpense.tr,
                            style:
                                TextStyle(color: Helper.getTextColor(context)),
                          ),
                          20.heightBox,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: InkWell(
                              onTap: () {
                                /*Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddSpendingScreen()),
                                    );*/
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Text(
                                  LocaleKeys.addSpending.tr,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          15.heightBox,
                        ],
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void clearSelection(StateSetter setState) {
    setState(() {
      isFilterCleared = true;
      for (var month in monthList) {
        month.isSelected = false;
      }
      for (var item in categoryList) {
        item.isSelected = false;
      }
      selectedMonths.clear();
      showMonth = LocaleKeys.selectMonth.tr;
      showYear = LocaleKeys.selectYear.tr;
      selectedCategoryIndex = -1;
      selectedCategory = '';
    });
  }

  getCategories() async {
    await DatabaseHelper.instance.categorys().then((value) {
      if (value.isNotEmpty) {
        for (var s in value) {
          categoryList.add(CommonCategoryModel(
              catId: s.id,
              catName: s.name,
              catType: AppConstanst.spendingTransaction));
        }
      }
    });
  }

  getFilteredData(String value) async {
    List<TransactionNewModel> spendingTransaction = [];
    dateWiseTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForYearMonthsAndCategory(
            showYear,
            selectedMonths,
            selectedCategoryIndex != -1
                ? categoryList[selectedCategoryIndex].catId!
                : -1,
            -1,
            currentUserKey,
        currentAccountKey,
            AppConstanst.spendingTransaction,
            value,
            isSkippedUser)
        .then((value) {
      spendingTransaction = value;
      List<String> dates = [];
      for (var t in spendingTransaction) {
        if (!dates.contains(t.transaction_date!.split(' ')[0])) {
          dates.add(t.transaction_date!.split(' ')[0]);
        }
      }
      dates.sort((a, b) => b.compareTo(a));
      totalMonthlySpentAmount = 0;
      for (var date in dates) {
        int totalAmount = 0;
        List<TransactionNewModel> newTransaction = [];
        for (var t in spendingTransaction) {
          if (date == t.transaction_date!.split(' ')[0]) {
            newTransaction.add(t);
            totalAmount = totalAmount + t.amount!;
          } else {
            DateWiseTransactionModel? found =
                dateWiseTransaction.firstWhereOrNull((element) =>
                    element.transactionDate!.split(' ')[0] == date);
            if (found == null) {
              continue;
            } else {
              break;
            }
          }
        }
        dateWiseTransaction.add(DateWiseTransactionModel(
            transactionDate: date,
            transactionTotal: totalAmount,
            transactionDay: Helper.getTransactionDay(date),
            transactions: newTransaction));
        totalMonthlySpentAmount = totalMonthlySpentAmount + totalAmount;
      }
      if (dateWiseTransaction.isNotEmpty) {
        var dates = dateWiseTransaction[0].transactionDate!.split('/');
        date = '${dates[1]}/${dates[2]}';
      }
      spendingPercentage = totalMonthlySpentAmount > 0
          ? (totalMonthlySpentAmount / actualBudget) * 100
          : 100;
      setState(() {});
    });
  }

  getProfileData() async {


      final reference = FirebaseDatabase.instance
          .reference()
          .child(accounts_table)
          .child(currentUserKey)
          .orderByChild(AccountTableFields.key)
          .equalTo(currentAccountKey);
      reference.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> values =
          dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
           var accountModel = AccountsModel.fromMap(value);
            currentBalance = int.parse(accountModel.balance!);
            actualBudget = int.parse(accountModel.budget!);
            double percentage = currentBalance > 0
                ? (currentBalance / actualBudget) * 100
                : 100;
            spendingPercentage = currentBalance > 0 ? 100 - percentage : 0;
          });
        }
      });

  }

  getTransactions(String category) async {
    date = DateFormat('MM/yyyy').format(DateTime.now());

    // showYear = DateFormat('yyyy').format(DateTime.now());
    //showMonth = DateFormat('MMMM').format(DateTime.now());

    if (isSkippedUser) {
      MySharedPreferences.instance
          .getStringValuesSF(SharedPreferencesKeys.skippedUserCurrentBalance)
          .then((value) {
        if (value != null) {
          currentBalance = int.parse(value);
          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.skippedUserActualBudget)
              .then((value) {
            if (value != null) {
              actualBudget = int.parse(value);
            }
          });
        }
      });
    } else {
      getProfileData();
    }

    List<TransactionNewModel> spendingTransaction = [];
    dateWiseTransaction = [];
    await DatabaseHelper.instance
        .getTransactionList(category.toLowerCase(), currentUserKey, currentAccountKey,
            AppConstanst.spendingTransaction, isSkippedUser)
        .then((value) async {
      spendingTransaction = value;
      List<String> dates = [];
      DateTime now = DateTime.now();
      String currentMonthName = DateFormat('MMMM').format(now);

      for (var t in spendingTransaction) {
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime parsedDate = format.parse(t.transaction_date!);
        String transactionMonthName = DateFormat('MMMM').format(parsedDate);
        if (transactionMonthName == currentMonthName) {
          if (!dates.contains(t.transaction_date!.split(' ')[0])) {
            dates.add(t.transaction_date!.split(' ')[0]);
          }
        }
      }

      dates.sort((a, b) => b.compareTo(a));
      totalMonthlySpentAmount = 0;
      for (var date in dates) {
        int totalAmount = 0;
        List<TransactionNewModel> newTransaction = [];
        for (var t in spendingTransaction) {
          if (date == t.transaction_date!.split(' ')[0]) {
            newTransaction.add(t);
            totalAmount = totalAmount + t.amount!;
          } else {
            DateWiseTransactionModel? found =
                dateWiseTransaction.firstWhereOrNull((element) =>
                    element.transactionDate!.split(' ')[0] == date);
            if (found == null) {
              continue;
            } else {
              break;
            }
          }
        }
        dateWiseTransaction.add(DateWiseTransactionModel(
            transactionDate: date,
            transactionTotal: totalAmount,
            transactionDay: Helper.getTransactionDay(date),
            transactions: newTransaction));
        originalDateWiseTransaction.add(DateWiseTransactionModel(
            transactionDate: date,
            transactionTotal: totalAmount,
            transactionDay: Helper.getTransactionDay(date),
            transactions: newTransaction));
        totalMonthlySpentAmount = totalMonthlySpentAmount + totalAmount;
      }

      if (dateWiseTransaction.isNotEmpty) {
        var dates = dateWiseTransaction[0].transactionDate!.split('/');
        date = '${dates[1]}/${dates[2]}';
      }
      double percentage = totalMonthlySpentAmount > 0
          ? (totalMonthlySpentAmount / actualBudget) * 100
          : 100;
      spendingPercentage = totalMonthlySpentAmount > 0 ? 100 - percentage : 0;
      setState(() {});
    });
  }

  @override
  void initState() {
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currentUserEmail)
        .then((value) {
      if (value != null) {
        currentUserEmail = value;
      }
      MySharedPreferences.instance
          .getStringValuesSF(SharedPreferencesKeys.userEmail)
          .then((value) {
        if (value != null) {
          userEmail = value;
        }
        MySharedPreferences.instance
            .getStringValuesSF(SharedPreferencesKeys.currentUserKey)
            .then((value) {
          if (value != null) {
            currentUserKey = value;
          }
          MySharedPreferences.instance
              .getIntValuesSF(SharedPreferencesKeys.userAccessType)
              .then((value) {
            if (value != null) {
              userAccess = value;
            }
          });

          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.currentAccountKey)
              .then((value) {
            if (value != null) {
              currentAccountKey = value;
            }
          });
          MySharedPreferences.instance
              .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
              .then((value) async {
            if (value != null) {
              isSkippedUser = value;
              getTransactions("");
            }
          });
        });
      });
    });
    getCategories();
    super.initState();
  }

  selectMonth(context, StateSetter setState) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState1) {
          return AlertDialog(
            title: Text(LocaleKeys.selectMonth.tr),
            contentPadding:
                const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2.2 / 1,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: monthList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState1(() {
                            monthList[index].isSelected = true;
                            for (int i = 0; i < monthList.length; i++) {
                              if (i != index) {
                                monthList[i].isSelected = false;
                              }
                            }
                          });
                          setState(() {
                            List<String> showMonthList = [];
                            selectedMonths = monthList
                                .where((month) => month.isSelected)
                                .toList();
                            for (var i in selectedMonths) {
                              showMonthList.add(i.text);
                            }
                            showMonth = showMonthList.join(", ");
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: monthList[index].isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Text(
                            monthList[index].text,
                            style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  selectYear(context, StateSetter setState) async {
    print("Calling date picker");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.selectYear.tr),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 10, 1),
              lastDate: DateTime.now(),
              //lastDate: DateTime(2025),
              initialDate: DateTime.now(),
              selectedDate: _selectedYear,
              onChanged: (DateTime dateTime) {
                setState(() {
                  _selectedYear = dateTime;
                  showYear = "${dateTime.year}";
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  _bottomSheetView(StateSetter setState) {
    return Container(
        padding: const EdgeInsets.only(bottom: 10),
        color: Helper.getBackgroundColor(context),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        clearSelection(setState);
                      },
                      child: Text(
                        LocaleKeys.clearFilter.tr,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        LocaleKeys.filter.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (isFilterCleared) {
                          isFilterCleared = false;
                          if (showYear != LocaleKeys.selectYear.tr &&
                              selectedMonths.isNotEmpty) {
                            Navigator.pop(context);
                            getFilteredData("");
                          }
                          if (showYear == LocaleKeys.selectYear.tr ||
                              selectedMonths.isEmpty) {
                            Navigator.pop(context);
                            getTransactions("");
                          } else if (showYear == LocaleKeys.selectYear.tr ||
                              selectedMonths.isEmpty) {
                            Helper.showToast(
                                LocaleKeys.selectMonthOrYearText.tr);
                          }
                        } else {
                          isFilterCleared = false;
                          if (showYear != LocaleKeys.selectYear.tr &&
                              selectedMonths.isNotEmpty) {
                            Navigator.pop(context);
                            getFilteredData("");
                          } else if (showYear == LocaleKeys.selectYear.tr ||
                              selectedMonths.isEmpty) {
                            Helper.showToast(
                                LocaleKeys.selectMonthOrYearText.tr);
                          } else {
                            Navigator.pop(context);
                            getTransactions("");
                          }
                        }
                      },
                      child: Text(
                        LocaleKeys.done.tr,
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.3,
                color: Helper.getTextColor(context),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.year.tr,
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 14),
                    ),
                    15.widthBox,
                    Text(
                      LocaleKeys.monthFilterText.tr,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          selectYear(context, setState);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 50),
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Text(
                            showYear,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      15.widthBox,
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectMonth(context, setState);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              showMonth,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  LocaleKeys.category.tr,
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 2,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (selectedCategoryIndex != -1) {
                            categoryList[selectedCategoryIndex].isSelected =
                                false;
                          }
                          categoryList[index].isSelected = true;
                          selectedCategoryIndex = index;
                          selectedCategory = categoryList[index].catName!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: categoryList[index].isSelected
                                ? Colors.blue
                                : Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          categoryList[index].catName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
              30.heightBox
            ],
          ),
        ));
  }
}
