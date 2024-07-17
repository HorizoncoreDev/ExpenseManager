import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/overview_screen/add_spending/add_spending_screen.dart';
import 'package:expense_manager/statistics/search/CommonCategoryModel.dart';
import 'package:expense_manager/statistics/search/search_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../db_models/transaction_new_model.dart';
import '../overview_screen/add_spending/DateWiseTransactionModel.dart';

class ChartData {
  final DateTime x;

  int y;

  ChartData(this.x, this.y);
}

class MonthData {
  final String text;
  bool isSelected;

  MonthData({required this.text, this.isSelected = false});
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  String spendingShowYear = LocaleKeys.selectYear.tr;
  String spendingShowMonth = LocaleKeys.selectMonth.tr;
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

  String incomeShowYear = LocaleKeys.selectYear.tr;
  String incomeShowMonth = LocaleKeys.selectMonth.tr;
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
  List<TransactionNewModel> spendingChartData = [];
  List<TransactionNewModel> incomeChartData = [];

  List<CommonCategoryModel> incomeCategoryList = [];
  List<CommonCategoryModel> spendingCategoryList = [];
  late int spendingSelectedCategory;
  String spendingSelectedCategoryName = "";
  int spendingSelectedCategoryIndex = -1;
  int spendingSelectedMonthIndex = -1;
  int incomeSelectedMonthIndex = -1;
  late int incomeSelectedCategory;
  String incomeSelectedCategoryName = "";
  int incomeSelectedCategoryIndex = -1;
  String userEmail = "";
  String currentUserEmail = "";
  String currentUserKey = "";
  String currentAccountKey = "";
  bool isSkippedUser = false;
  bool isSpendingFilterCleared = false;
  bool isIncomeFilterCleared = false;

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  bool showAvg = false;
  int userAccess = AppConstanst.viewOnlyAccess;
  int currPage = 1;
  String mDate = "";

  int totalAmount = 0;
  int totalIncomeAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 15,
          backgroundColor: Helper.getBackgroundColor(context),
          title: Text(LocaleKeys.statistics.tr,
              style: TextStyle(
                fontSize: 22,
                color: Helper.getTextColor(context),
              )),
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                              AppConstanst.selectedTabIndex = 0;
                              setState(() {
                                currPage = 1;
                              });
                              if (spendingShowYear !=
                                      LocaleKeys.selectYear.tr &&
                                  spendingShowMonth !=
                                      LocaleKeys.selectMonth.tr) {
                                getFilteredData();
                              } else {
                                getTransactions();
                              }
                            },
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                                    LocaleKeys.spending.tr,
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
                              AppConstanst.selectedTabIndex = 1;
                              setState(() {
                                currPage = 2;
                              });

                              if (incomeShowYear != LocaleKeys.selectYear.tr &&
                                  incomeShowMonth !=
                                      LocaleKeys.selectMonth.tr) {
                                getFilteredData();
                              } else {
                                getIncomeData();
                              }
                            },
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                                    LocaleKeys.income.tr,
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
              currPage == 1 ? Expanded(child: _spendingView()) : 0.heightBox,
              currPage == 2 ? Expanded(child: _incomeView()) : 0.heightBox,
              10.heightBox
            ],
          ),
        ));
  }

  double calculateInterval(double amount) {
    if (amount >= 100 && amount < 1000) {
      print("................................1");
      return 10;
    } else if (amount >= 1000 && amount < 10000) {
      print("................................2");
      return 100;
    } else if (amount >= 10000 && amount < 100000) {
      print("................................3");
      return 1000;
    } else if (amount >= 100000 && amount < 1000000) {
      print("................................4");
      return 10000;
    } else {
      // You can add more conditions for larger amounts if needed
      return 0; // or any default value
    }
  }

  double calculateRoundFigure(double amount) {
    final List<double> roundFigures = [
      100,
      1000,
      10000,
      100000,
      1000000,
      10000000
    ]; // Base values for round figures

    // Find the first round figure greater than or equal to the amount
    for (final figure in roundFigures) {
      if (amount <= figure) {
        return figure;
      }
    }

    // If no round figure is found (amount is very large), return the amount itself
    return amount;
  }

  Widget chartDataWidget(List<TransactionNewModel> spendingChartData, int type) {
    DateTime now = DateTime.now();

    List<ChartData> chartData;
    List<double> amounts = [];
    double highestAmount = 0;

    for (var item in spendingChartData) {
      if (item.transaction_date != null) {
        now = _parseDate(item.transaction_date!);
      }
      if (item.amount != null) {
        amounts.add(item.amount!.toDouble());
      } else {
        print("..........amount${item.amount}");
      }
    }

    chartData = generateChartDataForMonth(spendingChartData, now);

    if (amounts.isNotEmpty) {
      highestAmount =
          amounts.reduce((value, element) => value > element ? value : element);
    } else {
      highestAmount = 10000;
    }

    return SizedBox(
      height: 300,
      child: SfCartesianChart(
          plotAreaBackgroundColor: Colors.black,
          backgroundColor: Colors.transparent,
          plotAreaBackgroundImage:
              const AssetImage('asset/images/ic_phone.png'),
          tooltipBehavior: TooltipBehavior(
              enable: true, header: type == 1 ? "Spending" : "Income"),
          primaryYAxis: NumericAxis(
            borderColor: Colors.white,
            maximum: calculateRoundFigure(highestAmount ?? 10000),
            interval: calculateInterval(highestAmount ?? 1000),
            axisLabelFormatter: (AxisLabelRenderDetails details) {
              final num value = details.value;
              String text = value.toInt().toString();
              if (value.toInt() == 0) text = '0';
              if (value >= 1000) text = '${value ~/ 1000}K';
              if (value >= 1000000) text = '${value.toInt() / 1000000}M';
              return ChartAxisLabel(
                text,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.0,
                ),
              );
            },
          ),
          primaryXAxis: DateTimeAxis(
            labelStyle: const TextStyle(color: Colors.white),
            plotBands: const <PlotBand>[
              PlotBand(
                isVisible: true,
                color: Colors.white,
              ),
            ],
            maximum: DateTime(now.year, now.month + 1, 0),
            intervalType: DateTimeIntervalType.days,
            interval: 1, // To display every alternate day
          ),
          series: <CartesianSeries>[
            // Renders line chart
            SplineSeries<ChartData, DateTime>(
                color: type == 1 ? Colors.red : Colors.green,
                width: 3,
                splineType: SplineType.monotonic,
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y)
          ]),
    );
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
        spendingShowYear = LocaleKeys.selectYear.tr;
        spendingShowMonth = LocaleKeys.selectMonth.tr;
      } else {
        isIncomeFilterCleared = true;
        for (var item in incomeCategoryList) {
          item.isSelected = false;
        }
        for (var month in incomeMonthList) {
          month.isSelected = false;
        }
        incomeSelectedMonths.clear();
        incomeShowYear = LocaleKeys.selectYear.tr;
        incomeShowMonth = LocaleKeys.selectMonth.tr;
      }
    });
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateFormat('dd/MM/yyyy HH:mm').parse(dateStr);
    DateTime today = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return '${LocaleKeys.today.tr}, ${DateFormat('MM/dd/yyyy').format(dateTime)}';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return '${LocaleKeys.yesterday.tr}, ${DateFormat('MM/dd/yyyy').format(dateTime)}';
    } else {
      return DateFormat('MM/dd/yyyy').format(dateTime);
    }
  }

  List<ChartData> generateChartDataForMonth(
      List<TransactionNewModel> spendingChartData, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    List<ChartData> chartDataList = List.generate(daysInMonth,
        (i) => ChartData(DateTime(month.year, month.month, i + 1), 0));

    for (int i = 0; i < spendingChartData.length; i++) {
      TransactionNewModel transaction = spendingChartData[i];
      DateTime transactionDate = _parseDate(transaction.transaction_date!);
      if (transactionDate.month == month.month &&
          transactionDate.year == month.year) {
        int day = transactionDate.day;
        chartDataList[day - 1].y += transaction.amount!;
      }
    }

    return chartDataList;
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
          .fetchDataForYearMonthAndCategory(
              incomeShowYear,
              incomeShowMonth,
              -1,
              incomeSelectedCategoryIndex != -1
                  ? incomeCategoryList[incomeSelectedCategoryIndex].catId!
                  : -1,
              currentUserKey,
              currentAccountKey,
              AppConstanst.incomeTransaction,
              "",
              isSkippedUser)
          .then((value) {
        setState(() {
          if (value.isNotEmpty) {
            parseIncomeList(value);
          } else {
            getIncomeData();
            Helper.showToast(LocaleKeys.dataNotFound.tr);
          }
        });
      });
    } else {
      dateWiseSpendingTransaction = [];

      await DatabaseHelper.instance
          .fetchDataForYearMonthAndCategory(
              spendingShowYear,
              spendingShowMonth,
              spendingSelectedCategoryIndex != -1
                  ? spendingCategoryList[spendingSelectedCategoryIndex].catId!
                  : -1,
              -1,
              currentUserKey,
              currentAccountKey,
              AppConstanst.spendingTransaction,
              "",
              isSkippedUser)
          .then((value) {
        setState(() {
          if (value.isNotEmpty) {
            parseSpendingList(value);
          } else {
            getTransactions();
            Helper.showToast(LocaleKeys.dataNotFound.tr);
          }
        });
      });
    }
  }

  getIncomeData() async {
    dateWiseIncomeTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(AppConstanst.incomeTransaction,
            currentUserKey, currentAccountKey, isSkippedUser)
        .then((value) {
      parseIncomeList(value);
    });
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

  getTransactions() async {
    dateWiseSpendingTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(AppConstanst.spendingTransaction,
            currentUserKey, currentAccountKey, isSkippedUser)
        .then((value) {
      parseSpendingList(value);
    });
  }

  @override
  void initState() {
    AppConstanst.selectedTabIndex = 0;
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
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
            MySharedPreferences.instance
                .getStringValuesSF(SharedPreferencesKeys.userEmail)
                .then((value) {
              if (value != null) {
                userEmail = value;
                MySharedPreferences.instance
                    .getStringValuesSF(SharedPreferencesKeys.currentUserEmail)
                    .then((value) {
                  if (value != null) {
                    currentUserEmail = value;
                    MySharedPreferences.instance
                        .getIntValuesSF(SharedPreferencesKeys.userAccessType)
                        .then((value) {
                      if (value != null) {
                        userAccess = value;
                      }
                    });
                    getTransactions();
                  }
                });
              }
            });
          }
        });}
        });
      }
    });

    getCategories();
    super.initState();
  }

  parseIncomeList(List<TransactionNewModel> value) {
    List<TransactionNewModel> incomeTransaction = [];
    incomeTransaction = value;
    incomeChartData = value;
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
      List<TransactionNewModel> newTransaction = [];
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

  parseSpendingList(List<TransactionNewModel> value) {
    List<TransactionNewModel> spendingTransaction = [];
    spendingTransaction = value;
    spendingChartData = value;
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
      List<TransactionNewModel> newTransaction = [];
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
                    itemCount: currPage == 1
                        ? spendingMonthList.length
                        : incomeMonthList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState1(() {
                            if (currPage == 1) {
                              if (spendingSelectedMonthIndex != -1) {
                                spendingMonthList[spendingSelectedMonthIndex]
                                    .isSelected = false;
                              }
                              spendingMonthList[index].isSelected = true;
                              spendingSelectedMonthIndex = index;
                              spendingShowMonth = spendingMonthList[index].text;
                              setState(() {});
                              Navigator.pop(context);
                              //spendingMonthList[index].isSelected = !spendingMonthList[index].isSelected;
                            } else {
                              if (incomeSelectedMonthIndex != -1) {
                                incomeMonthList[incomeSelectedMonthIndex]
                                    .isSelected = false;
                              }
                              incomeMonthList[index].isSelected = true;
                              incomeSelectedMonthIndex = index;
                              incomeShowMonth = incomeMonthList[index].text;
                              setState(() {});
                              Navigator.pop(context);
                              //incomeMonthList[index].isSelected = !incomeMonthList[index].isSelected;
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
            /*actions: [
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
            ]*/
          );
        });
      },
    );
  }

  selectYear(context, StateSetter setState) async {
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
                        if (currPage == 1) {
                          if (isSpendingFilterCleared) {
                            Navigator.pop(context);
                            getTransactions();
                          } else {
                            isSpendingFilterCleared = false;

                            if (spendingShowYear != LocaleKeys.selectYear.tr &&
                                spendingShowMonth !=
                                    LocaleKeys.selectMonth.tr) {
                              Navigator.pop(context);
                              getFilteredData();
                            } else if (spendingShowYear ==
                                    LocaleKeys.selectYear.tr ||
                                spendingShowMonth ==
                                    LocaleKeys.selectMonth.tr) {
                              Helper.showToast(
                                  LocaleKeys.selectMonthOrYearText.tr);
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

                            if (incomeShowYear != LocaleKeys.selectYear.tr &&
                                incomeShowMonth != LocaleKeys.selectMonth.tr) {
                              Navigator.pop(context);
                              getFilteredData();
                            } else if (incomeShowYear ==
                                    LocaleKeys.selectYear.tr ||
                                incomeShowMonth == LocaleKeys.selectMonth.tr) {
                              Helper.showToast(
                                  LocaleKeys.selectMonthOrYearText.tr);
                            } else {
                              Navigator.pop(context);
                              getTransactions();
                            }
                          }
                        }
                      },
                      child: Text(
                        LocaleKeys.done.tr,
                        style: const TextStyle(
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
                  LocaleKeys.category.tr,
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

  Widget _incomeView() {
    bool currentEmail = userEmail.isNotEmpty
        ? userEmail == currentUserEmail
            ? true
            : userAccess == AppConstanst.editAccess
                ? true
                : false
        : true;
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
                  child: chartDataWidget(incomeChartData, 2)),
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
                            "+${AppConstanst.currencySymbol}${dateWiseIncomeTransaction[index].transactionTotal}",
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
                                        "+${AppConstanst.currencySymbol}${dateWiseIncomeTransaction[index].transactions![index1].amount}",
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
                width: double.maxFinite,
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
                        LocaleKeys.dontHaveIncome.tr,
                        style: TextStyle(color: Helper.getTextColor(context)),
                      ),
                      20.heightBox,
                      if (currentEmail)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true)
                                  .push(
                                MaterialPageRoute(
                                    builder: (context) => AddSpendingScreen(
                                          transactionName: AppConstanst
                                              .incomeTransactionName,
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
                              child: Text(
                                LocaleKeys.addIncome.tr,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
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

  DateTime _parseDate(String dateString) {
    // Assuming date format: dd/MM/yyyy HH:mm
    List<String> parts = dateString.split(' ');
    List<String> dateParts = parts[0].split('/');
    List<String> timeParts = parts[1].split(':');

    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    return DateTime(year, month, day, hour, minute);
  }

  Widget _spendingView() {
    bool currentEmail = userEmail.isNotEmpty
        ? userEmail == currentUserEmail
            ? true
            : userAccess == AppConstanst.editAccess
                ? true
                : false
        : true;
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
                child: chartDataWidget(spendingChartData, 1),
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
                            "-${AppConstanst.currencySymbol}${dateWiseSpendingTransaction[index].transactionTotal}",
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
                                        "-${AppConstanst.currencySymbol}${dateWiseSpendingTransaction[index].transactions![index1].amount}",
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
                width: double.maxFinite,
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
                        style: TextStyle(color: Helper.getTextColor(context)),
                      ),
                      20.heightBox,
                      if (currentEmail)
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
                              child: Text(
                                LocaleKeys.addSpending.tr,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
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
}
