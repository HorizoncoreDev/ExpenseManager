import 'dart:math';

import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/overview_screen/add_spending/add_spending_screen.dart';
import 'package:expense_manager/statistics/search/CommonCategoryModel.dart';
import 'package:expense_manager/statistics/search/search_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';

import '../overview_screen/add_spending/DateWiseTransactionModel.dart';
import '../utils/my_shared_preferences.dart';
import 'bloc/statistics_bloc.dart';
import 'bloc/statistics_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsBloc statisticsBloc = StatisticsBloc();
  String spendingShowYear = 'Select Year';
  String spendingShowMonth = 'Select month';
  DateTime _spendingSelectedYear = DateTime.now();
  List<MonthData> spendingSelectedMonths = [];
  List<MonthData> spendingMonthList = [
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

  String incomeShowYear = 'Select Year';
  String incomeShowMonth = 'Select month';
  DateTime _incomeSelectedYear = DateTime.now();
  List<MonthData> incomeSelectedMonths = [];
  List<MonthData> incomeMonthList = [
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

  List<DateWiseTransactionModel> dateWiseSpendingTransaction = [];
  List<DateWiseTransactionModel> dateWiseIncomeTransaction = [];

  List<CommonCategoryModel> incomeCategoryList = [];
  List<CommonCategoryModel> spendingCategoryList = [];
  late int spendingSelectedCategory;
  String spendingSelectedCategoryName = "";
  int spendingSelectedCategoryIndex = -1;
  late int incomeSelectedCategory;
  String incomeSelectedCategoryName = "";
  int incomeSelectedCategoryIndex = -1;
  String userEmail = "";
  bool isSpendingFilterCleared = false;
  bool isIncomeFilterCleared = false;

  @override
  void initState() {
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
      }
      getTransactions();
    });

    getCategories();
    super.initState();
  }

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  bool showAvg = false;
  int currPage = 1;

  String mDate = "";
  int totalAmount = 0;
  int totalIncomeAmount = 0;

  getTransactions() async {
    dateWiseSpendingTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(AppConstanst.spendingTransaction, userEmail)
        .then((value) {
      parseSpendingList(value);
    });
  }

  parseSpendingList(List<TransactionModel> value) {
    List<TransactionModel> spendingTransaction = [];
    spendingTransaction = value;
    List<String> dates = [];

    for (var t in spendingTransaction) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      DateTime parsedDate = format.parse(t.transaction_date!);
      String transactionMonthYear = DateFormat('MMMM/yyyy').format(parsedDate);
      if (!dates.contains(transactionMonthYear)) {
        dates.add(transactionMonthYear);
      }
    }

    dates.sort((a, b) => b.compareTo(a));
    for (var date in dates) {
      int totalAmount = 0;
      List<TransactionModel> newTransaction = [];
      for (var t in spendingTransaction) {
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime parsedDate = format.parse(t.transaction_date!);
        String transactionMonthYear =
            DateFormat('MMMM/yyyy').format(parsedDate);

        if (date == transactionMonthYear) {
          newTransaction.add(t);
          totalAmount = totalAmount + t.amount!;
        } else {
          DateWiseTransactionModel? found =
              dateWiseSpendingTransaction.firstWhereOrNull((element) {
            return element.transactionDate! == date;
          });
          if (found == null) {
            continue;
          } else {
            break;
          }
        }
      }
      dateWiseSpendingTransaction.add(DateWiseTransactionModel(
          transactionDate: date,
          transactionTotal: totalAmount,
          transactionDay: "",
          transactions: newTransaction));
    }
    setState(() {});
  }

  getIncomeData() async {
    dateWiseIncomeTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(AppConstanst.incomeTransaction, userEmail)
        .then((value) {
      parseIncomeList(value);
    });
  }

  parseIncomeList(List<TransactionModel> value) {
    List<TransactionModel> incomeTransaction = [];
    incomeTransaction = value;
    List<String> dates = [];

    for (var t in incomeTransaction) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      DateTime parsedDate = format.parse(t.transaction_date!);
      String transactionMonthYear = DateFormat('MMMM/yyyy').format(parsedDate);
      if (!dates.contains(transactionMonthYear)) {
        dates.add(transactionMonthYear);
      }
    }

    dates.sort((a, b) => b.compareTo(a));
    for (var date in dates) {
      int totalAmount = 0;
      List<TransactionModel> newTransaction = [];
      for (var t in incomeTransaction) {
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime parsedDate = format.parse(t.transaction_date!);
        String transactionMonthYear =
            DateFormat('MMMM/yyyy').format(parsedDate);

        if (date == transactionMonthYear) {
          newTransaction.add(t);
          totalAmount = totalAmount + t.amount!;
        } else {
          DateWiseTransactionModel? found =
              dateWiseIncomeTransaction.firstWhereOrNull((element) {
            return element.transactionDate! == date;
          });
          if (found == null) {
            continue;
          } else {
            break;
          }
        }
      }
      dateWiseIncomeTransaction.add(DateWiseTransactionModel(
          transactionDate: date,
          transactionTotal: totalAmount,
          transactionDay: "",
          transactions: newTransaction));
    }
    setState(() {});
  }

  String? getMonth(String date) {
    List<String> dateTimeComponents = date.split(' ');
    List<String> dateComponents = dateTimeComponents[0].split('/');
    List<String> timeComponents = dateTimeComponents[1].split(':');

    // Extract individual components
    int day = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int year = int.parse(dateComponents[2]);
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    final originalDate = DateTime(year, month, day, hour, minute);
    return DateFormat('MMMM/yyyy').format(originalDate);
  }

  getCategories() async {
    await DatabaseHelper.instance.categorys().then((value) {
      if (value.isNotEmpty) {
        for (var s in value) {
          spendingCategoryList
              .add(CommonCategoryModel(catId: s.id, catName: s.name));
        }
      }
    });
    await DatabaseHelper.instance.getIncomeCategory().then((value) {
      if (value.isNotEmpty) {
        for (var s in value) {
          incomeCategoryList
              .add(CommonCategoryModel(catId: s.id, catName: s.name));
        }
      }
    });
  }

  getFilteredData() async {
    if (currPage == 2) {
      dateWiseIncomeTransaction = [];
      await DatabaseHelper.instance
          .fetchDataForYearMonthsAndCategory(
              incomeShowYear,
              incomeSelectedMonths,
              -1,
              incomeSelectedCategoryIndex != -1
                  ? incomeCategoryList[incomeSelectedCategoryIndex].catId!
                  : -1,
              userEmail,
              AppConstanst.incomeTransaction,
              "")
          .then((value) {
        setState(() {
          if (value.isNotEmpty) {
            parseIncomeList(value);
          } else {
            getIncomeData();
            Helper.showToast("Data not found");
          }
        });
      });
    } else {
      dateWiseSpendingTransaction = [];

      await DatabaseHelper.instance
          .fetchDataForYearMonthsAndCategory(
              spendingShowYear,
              spendingSelectedMonths,
              spendingSelectedCategoryIndex != -1
                  ? spendingCategoryList[spendingSelectedCategoryIndex].catId!
                  : -1,
              -1,
              userEmail,
              AppConstanst.spendingTransaction,
              "")
          .then((value) {
        setState(() {
          if (value.isNotEmpty) {
            parseSpendingList(value);
          } else {
            getTransactions();
            Helper.showToast("Data not found");
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    statisticsBloc.context = context;
    return BlocConsumer<StatisticsBloc, StatisticsState>(
      bloc: statisticsBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is StatisticsInitial) {
          return Scaffold(
              appBar: AppBar(
                titleSpacing: 15,
                backgroundColor: Helper.getBackgroundColor(context),
                title: Text("Statistics",
                    style: TextStyle(
                      fontSize: 22,
                      color: Helper.getTextColor(context),
                    )),
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Helper.getCardColor(context)),
                      child: Icon(
                        Icons.search,
                        color: Helper.getTextColor(context),
                        size: 20,
                      ),
                    ),
                  ),
                  10.widthBox,
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
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return WillPopScope(
                                  onWillPop: () async {
                                    return true;
                                  },
                                  child: Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: _bottomSheetView(
                                          statisticsBloc, setState)));
                            });
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
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
                  /*  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => OtherScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Helper.getCardColor(context)),
                        child: const Icon(
                          Icons.family_restroom_sharp,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  )*/
                ],
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: Helper.getBackgroundColor(context),
                child: Column(
                  children: [
                    20.heightBox,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Helper.getCardColor(context),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      currPage = 1;
                                    });
                                    if (spendingShowYear != "Select Year" &&
                                        spendingSelectedMonths.isNotEmpty) {
                                      getFilteredData();
                                    } else {
                                      getTransactions();
                                    }
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              bottomLeft: Radius.circular(30)),
                                          color: currPage == 1
                                              ? Colors.blue
                                              : Helper.getCardColor(context)),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Spending',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: currPage == 1
                                                ? Colors.white
                                                : Helper.getTextColor(context),
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      currPage = 2;
                                    });
                                    if (incomeShowYear != "Select Year" &&
                                        incomeSelectedMonths.isNotEmpty) {
                                      getFilteredData();
                                    } else {
                                      getIncomeData();
                                    }
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(30),
                                              bottomRight: Radius.circular(30)),
                                          color: currPage == 2
                                              ? Colors.blue
                                              : Helper.getCardColor(context)),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Income',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: currPage == 2
                                                ? Colors.white
                                                : Helper.getTextColor(context),
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          )),
                    ),
                    currPage == 1
                        ? Expanded(child: _spendingView(statisticsBloc))
                        : 0.heightBox,
                    currPage == 2
                        ? Expanded(child: _incomeView(statisticsBloc))
                        : 0.heightBox,
                    10.heightBox
                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }

  Widget _spendingView(StatisticsBloc statisticsBloc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          20.heightBox,
          Container(
            color: Helper.getCardColor(context),
            child: AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: Chart(
                  // layers: layers(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0).copyWith(
                    bottom: 12.0,
                  ),
                ),
              ),
            ),
          ),
          15.heightBox,
          if (dateWiseSpendingTransaction.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: dateWiseSpendingTransaction.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateWiseSpendingTransaction[index].transactionDate!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "-\u20B9${dateWiseSpendingTransaction[index].transactionTotal}",
                            style: const TextStyle(
                                color: Colors.pink, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    15.heightBox,
                    if (dateWiseSpendingTransaction[index]
                        .transactions!
                        .isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: dateWiseSpendingTransaction[index]
                            .transactions!
                            .length,
                        itemBuilder: (context, index1) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.yellow),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black),
                                      child: SvgPicture.asset(
                                        'asset/images/${dateWiseSpendingTransaction[index].transactions![index1].cat_icon}.svg',
                                        color:
                                            dateWiseSpendingTransaction[index]
                                                .transactions![index1]
                                                .cat_color,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                  15.widthBox,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateWiseSpendingTransaction[index]
                                              .transactions![index1]
                                              .cat_name!,
                                          style: TextStyle(
                                              color:
                                                  Helper.getTextColor(context),
                                              fontSize: 16),
                                        ),
                                        Text(
                                          dateWiseSpendingTransaction[index]
                                              .transactions![index1]
                                              .description!,
                                          style: TextStyle(
                                              color:
                                                  Helper.getTextColor(context),
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "-\u20B9${dateWiseSpendingTransaction[index].transactions![index1].amount}",
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 16),
                                      ),
                                      Text(
                                        formatDate(
                                            dateWiseSpendingTransaction[index]
                                                .transactions![index1]
                                                .transaction_date!),
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 14),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return 10.heightBox;
                        },
                      ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return 15.heightBox;
              },
            ),
          10.heightBox,
          if (dateWiseSpendingTransaction.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                        "You don't have any expenses yet",
                        style: TextStyle(color: Helper.getTextColor(context)),
                      ),
                      20.heightBox,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .push(
                              MaterialPageRoute(
                                  builder: (context) => AddSpendingScreen(
                                        transactionName: AppConstanst
                                            .spendingTransactionName,
                                      )),
                            )
                                .then((value) {
                              if (value != null) {
                                if (value) {
                                  getTransactions();
                                }
                              }
                            });
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
                            child: const Text(
                              "Add spending",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      15.heightBox,
                    ],
                  )),
            ),
        ],
      ),
    );
  }

  Widget _incomeView(StatisticsBloc statisticsBloc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          20.heightBox,
          Container(
            color: Helper.getCardColor(context),
            child: AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  mainData(),
                ),
              ),
            ),
          ),
          15.heightBox,
          if (dateWiseIncomeTransaction.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: dateWiseIncomeTransaction.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateWiseIncomeTransaction[index].transactionDate!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "+\u20B9${dateWiseIncomeTransaction[index].transactionTotal}",
                            style: const TextStyle(
                                color: Colors.green, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    15.heightBox,
                    if (dateWiseIncomeTransaction[index]
                        .transactions!
                        .isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: dateWiseIncomeTransaction[index]
                            .transactions!
                            .length,
                        itemBuilder: (context, index1) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.yellow),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black),
                                      child: SvgPicture.asset(
                                        'asset/images/${dateWiseIncomeTransaction[index].transactions![index1].cat_icon}.svg',
                                        color: dateWiseIncomeTransaction[index]
                                            .transactions![index1]
                                            .cat_color,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                  15.widthBox,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateWiseIncomeTransaction[index]
                                              .transactions![index1]
                                              .cat_name!,
                                          style: TextStyle(
                                              color:
                                                  Helper.getTextColor(context),
                                              fontSize: 16),
                                        ),
                                        Text(
                                          dateWiseIncomeTransaction[index]
                                              .transactions![index1]
                                              .description!,
                                          style: TextStyle(
                                              color:
                                                  Helper.getTextColor(context),
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "+\u20B9${dateWiseIncomeTransaction[index].transactions![index1].amount}",
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 16),
                                      ),
                                      Text(
                                        formatDate(
                                            dateWiseIncomeTransaction[index]
                                                .transactions![index1]
                                                .transaction_date!),
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 14),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
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
          10.heightBox,
          if (dateWiseIncomeTransaction.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                        "You don't have any income yet",
                        style: TextStyle(color: Helper.getTextColor(context)),
                      ),
                      20.heightBox,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .push(
                              MaterialPageRoute(
                                  builder: (context) => AddSpendingScreen(
                                        transactionName:
                                            AppConstanst.incomeTransactionName,
                                      )),
                            )
                                .then((value) {
                              if (value != null) {
                                if (value) {
                                  getIncomeData();
                                }
                              }
                            });
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
                            child: const Text(
                              "Add income",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      15.heightBox,
                    ],
                  )),
            ),
        ],
      ),
    );
  }

  _bottomSheetView(StatisticsBloc statisticsBloc, StateSetter setState) {
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
                        "Clear filter",
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Filter",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (currPage == 1) {
                          if (isSpendingFilterCleared) {
                            Navigator.pop(context);
                            getTransactions();
                          } else {
                            isSpendingFilterCleared = false;
                            if (spendingShowYear != "Select Year" &&
                                spendingSelectedMonths.isNotEmpty) {
                              Navigator.pop(context);
                              getFilteredData();
                            } else if (spendingShowYear == "Select Year" ||
                                spendingSelectedMonths.isEmpty) {
                              Helper.showToast(
                                  "Please ensure you select a year and month to retrieve data");
                            } else {
                              Navigator.pop(context);
                              getTransactions();
                            }
                          }
                        } else {
                          if (isSpendingFilterCleared) {
                            Navigator.pop(context);
                            getTransactions();
                          } else {
                            isIncomeFilterCleared = false;
                            if (incomeShowYear != "Select Year" &&
                                incomeSelectedMonths.isNotEmpty) {
                              Navigator.pop(context);
                              getFilteredData();
                            } else if (incomeShowYear == "Select Year" ||
                                incomeSelectedMonths.isEmpty) {
                              Helper.showToast(
                                  "Please ensure you select a year and month to retrieve data");
                            } else {
                              Navigator.pop(context);
                              getTransactions();
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Done",
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
                      "YEAR",
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 14),
                    ),
                    15.widthBox,
                    Text(
                      "MONTH(Can filter one or more)",
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
                            currPage == 1 ? spendingShowYear : incomeShowYear,
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
                              currPage == 1
                                  ? spendingShowMonth
                                  : incomeShowMonth,
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
                  "CATEGORY",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
              ),
              if (currPage == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: spendingCategoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (spendingSelectedCategoryIndex != -1) {
                              spendingCategoryList[
                                      spendingSelectedCategoryIndex]
                                  .isSelected = false;
                            }
                            spendingCategoryList[index].isSelected = true;
                            spendingSelectedCategoryIndex = index;
                            spendingSelectedCategory =
                                spendingCategoryList[index].catId!;
                            spendingSelectedCategoryName =
                                spendingCategoryList[index].catName!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: spendingCategoryList[index].isSelected
                                  ? Colors.blue
                                  : Helper.getCardColor(context),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              spendingCategoryList[index].catName ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (currPage == 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: incomeCategoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (incomeSelectedCategoryIndex != -1) {
                              incomeCategoryList[incomeSelectedCategoryIndex]
                                  .isSelected = false;
                            }
                            incomeCategoryList[index].isSelected = true;
                            incomeSelectedCategoryIndex = index;
                            incomeSelectedCategory =
                                incomeCategoryList[index].catId!;
                            incomeSelectedCategoryName =
                                incomeCategoryList[index].catName!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: incomeCategoryList[index].isSelected
                                  ? Colors.blue
                                  : Helper.getCardColor(context),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              incomeCategoryList[index].catName ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ));
  }

  void clearSelection(StateSetter setState) {
    setState(() {
      if (currPage == 1) {
        isSpendingFilterCleared = true;
        for (var item in spendingCategoryList) {
          item.isSelected = false;
        }
        for (var month in spendingMonthList) {
          month.isSelected = false;
        }
        spendingSelectedMonths.clear();
        spendingShowYear = 'Select Year';
        spendingShowMonth = 'Select Month';
      } else {
        isIncomeFilterCleared = true;
        for (var item in incomeCategoryList) {
          item.isSelected = false;
        }
        for (var month in incomeMonthList) {
          month.isSelected = false;
        }
        incomeSelectedMonths.clear();
        incomeShowYear = 'Select Year';
        incomeShowMonth = 'Select Month';
      }
    });
  }

  /* Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Helper.getTextColor(context),
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('1', style: style);
        break;
      case 1:
        text = Text('3', style: style);
        break;
      case 2:
        text = Text('5', style: style);
        break;
      case 3:
        text = Text('7', style: style);
        break;
      case 4:
        text = Text('9', style: style);
        break;
      case 5:
        text = Text('11', style: style);
        break;
      case 6:
        text = Text('13', style: style);
        break;
      case 7:
        text = Text('15', style: style);
        break;
      case 8:
        text = Text('17', style: style);
        break;
      case 9:
        text = Text('19', style: style);
        break;
      case 10:
        text = Text('21', style: style);
        break;
      case 11:
        text = Text('23', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }*/

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Helper.getTextColor(context),
      fontSize: 12,
    );
    Widget text;

    int dayOfMonth = value.toInt();
    if (dayOfMonth % 2 != 0 && dayOfMonth >= 1 && dayOfMonth <= 31) {
      text = Text('$dayOfMonth', style: style);
    } else {
      text = Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 1:
        text = '4k';
        break;
      case 2:
        text = '8k';
        break;
      case 3:
        text = '12k';
        break;
      case 4:
        text = '16k';
        break;
      case 5:
        text = '20k';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(color: Helper.getTextColor(context)),
        textAlign: TextAlign.left);
  }

  List<FlSpot> chartData = [
    const FlSpot(0, 1),
    const FlSpot(1, 3),
    const FlSpot(2, 1),
    const FlSpot(3, 7),
    const FlSpot(4, 1),
    const FlSpot(5, 1),
    const FlSpot(6, 1),
    const FlSpot(7, 1),
    const FlSpot(8, 0),
  ];

  LineChartData mainData() {
    return LineChartData(
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: chartData,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateFormat('dd/MM/yyyy HH:mm').parse(dateStr);
    DateTime today = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return 'Today, ${DateFormat('MM/dd/yyyy').format(dateTime)}';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday, ${DateFormat('MM/dd/yyyy').format(dateTime)}';
    } else {
      return DateFormat('MM/dd/yyyy').format(dateTime);
    }
  }

  selectYear(context, StateSetter setState) async {
    print("Calling date picker");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 10, 1),
              lastDate: DateTime.now(),
              //lastDate: DateTime(2025),
              initialDate: DateTime.now(),
              selectedDate:
                  currPage == 1 ? _spendingSelectedYear : _incomeSelectedYear,
              onChanged: (DateTime dateTime) {
                print(dateTime.year);
                setState(() {
                  if (currPage == 1) {
                    _spendingSelectedYear = dateTime;
                    spendingShowYear = "${dateTime.year}";
                  } else {
                    _incomeSelectedYear = dateTime;
                    incomeShowYear = "${dateTime.year}";
                  }
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  selectMonth(context, StateSetter setState) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState1) {
          return AlertDialog(
            title: const Text("Select Month"),
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
                    itemCount: currPage == 1
                        ? spendingMonthList.length
                        : incomeMonthList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState1(() {
                            if (currPage == 1) {
                              spendingMonthList[index].isSelected =
                                  !spendingMonthList[index].isSelected;
                            } else {
                              incomeMonthList[index].isSelected =
                                  !incomeMonthList[index].isSelected;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: currPage == 1
                                  ? spendingMonthList[index].isSelected
                                      ? Colors.blue
                                      : Colors.transparent
                                  : incomeMonthList[index].isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Text(
                            currPage == 1
                                ? spendingMonthList[index].text
                                : incomeMonthList[index].text,
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
            actions: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (currPage == 1) {
                      List<String> showMonthList = [];
                      spendingSelectedMonths = spendingMonthList
                          .where((month) => month.isSelected)
                          .toList();
                      for (var i in spendingSelectedMonths) {
                        showMonthList.add(i.text);
                      }
                      spendingShowMonth = showMonthList.join(", ");
                      Navigator.pop(context);
                    } else {
                      List<String> showMonthList = [];
                      incomeSelectedMonths = incomeMonthList
                          .where((month) => month.isSelected)
                          .toList();
                      for (var i in incomeSelectedMonths) {
                        showMonthList.add(i.text);
                      }
                      incomeShowMonth = showMonthList.join(", ");
                      Navigator.pop(context);
                    }
                  });
                },
                child: const Text(
                  "Done",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              )
            ],
          );
        });
      },
    );
  }

  /*List<ChartLayer> layers() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1); // Start of current month
    final to = DateTime(now.year, now.month + 1, 0); // End of current month

    // Calculate number of weeks in the current month
    final daysInMonth = to.day;
    final weeksInMonth = ((daysInMonth - 1) / 7).ceil();

    // Calculate frequency based on number of weeks
    final frequency = daysInMonth / weeksInMonth;

   */
  /* final from = DateTime(2021, 1);
    final to = DateTime(2021, 12);
    final frequency =
        (to.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / 12.0;*/
  /*

    return [
      ChartHighlightLayer(
        shape: () => ChartHighlightLineShape<ChartLineDataItem>(
          backgroundColor: const Color(0xFF331B6D),
          currentPos: (item) => item.currentValuePos,
          radius: const BorderRadius.all(Radius.circular(8.0)),
          width: 60.0,
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: frequency.toDouble(),
            max: to.millisecondsSinceEpoch.toDouble(),
            min: from.millisecondsSinceEpoch.toDouble(),
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
          y: ChartAxisSettingsAxis(
            frequency: 100.0,
            max: 400.0,
            min: 0.0,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
        ),
        labelX: (value) => DateFormat('MMM')
            .format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartLineLayer(
        items: List.generate(
          4,
          (index) => ChartLineDataItem(
            x: (index * frequency.toDouble()) + from.millisecondsSinceEpoch,
            value: Random().nextInt(380) + 20,
          ),
        ),
        settings: const ChartLineSettings(
          color: Color(0xFF8043F9),
          thickness: 4.0,
        ),
      ),
      ChartTooltipLayer(
        shape: () => ChartTooltipLineShape<ChartLineDataItem>(
          backgroundColor: Colors.white,
          circleBackgroundColor: Colors.white,
          circleBorderColor: const Color(0xFF331B6D),
          circleSize: 4.0,
          circleBorderThickness: 2.0,
          currentPos: (item) => item.currentValuePos,
          onTextValue: (item) => '€${item.value.toString()}',
          marginBottom: 6.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          radius: 6.0,
          textStyle: const TextStyle(
            color: Color(0xFF8043F9),
            letterSpacing: 0.2,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];
  }*/

  List<ChartLayer> layers() {
    final from = DateTime(2021, 1, 1);
    final to = DateTime(2021, 12, 31);
    final frequency = (to.difference(from).inDays) / 12.0;

    return [
      ChartHighlightLayer(
        shape: () => ChartHighlightLineShape<ChartLineDataItem>(
          backgroundColor: const Color(0xFF331B6D),
          currentPos: (item) => item.currentValuePos,
          radius: const BorderRadius.all(Radius.circular(8.0)),
          width: 60.0,
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: frequency.toDouble(),
            max: to.millisecondsSinceEpoch.toDouble(),
            min: from.millisecondsSinceEpoch.toDouble(),
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
          y: ChartAxisSettingsAxis(
            frequency: 100.0,
            max: 400.0,
            min: 0.0,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
        ),
        labelX: (value) => DateFormat('MMM')
            .format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartLineLayer(
        items: List.generate(
          4,
          (index) => ChartLineDataItem(
            x: (index * frequency.toDouble()) + from.millisecondsSinceEpoch,
            value: Random().nextInt(380) + 20,
          ),
        ),
        settings: const ChartLineSettings(
          color: Color(0xFF8043F9),
          thickness: 4.0,
        ),
      ),
      ChartTooltipLayer(
        shape: () => ChartTooltipLineShape<ChartLineDataItem>(
          backgroundColor: Colors.white,
          circleBackgroundColor: Colors.white,
          circleBorderColor: const Color(0xFF331B6D),
          circleSize: 4.0,
          circleBorderThickness: 2.0,
          currentPos: (item) => item.currentValuePos,
          onTextValue: (item) => '€${item.value.toString()}',
          marginBottom: 6.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          radius: 6.0,
          textStyle: const TextStyle(
            color: Color(0xFF8043F9),
            letterSpacing: 0.2,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];
  }
}

class MonthData {
  final String text;
  bool isSelected;

  MonthData({required this.text, this.isSelected = false});
}
