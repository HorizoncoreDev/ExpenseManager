import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/overview_screen/add_spending/add_spending_screen.dart';
import 'package:expense_manager/statistics/search/search_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../other_screen/other_screen.dart';
import 'bloc/statistics_bloc.dart';
import 'bloc/statistics_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsBloc statisticsBloc = StatisticsBloc();

  List<TransactionModel> spendingTransaction = [];
  List<TransactionModel> incomeTransaction = [];

  @override
  void initState() {
    getTransactions();
    getIncomeData();
    super.initState();
  }

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  List<GridItem> gridItemList = [
    GridItem(text: 'Dine out'),
    GridItem(text: 'Living'),
    GridItem(text: 'Commuting'),
    GridItem(text: 'Wear'),
    GridItem(text: 'Enjoyment'),
    GridItem(text: 'Child care'),
    GridItem(text: 'Gift'),
    GridItem(text: 'Housing'),
    GridItem(text: 'Health'),
    GridItem(text: 'Personal'),
    GridItem(text: 'Other'),
  ];

  bool showAvg = false;
  int currPage = 1;

  String mDate = "";
  int totalAmount = 0;
  int totalIncomeAmount = 0;

  getTransactions() async {
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(AppConstanst.spendingTransaction)
        .then((value) {
      setState(() {
        spendingTransaction = value;
        for (var item in spendingTransaction) {
          totalAmount += item.amount ?? 0;
          // Split the date string into its components
          List<String> dateTimeComponents = item.transaction_date!.split(' ');
          List<String> dateComponents = dateTimeComponents[0].split('/');
          List<String> timeComponents = dateTimeComponents[1].split(':');

          // Extract individual components
          int day = int.parse(dateComponents[0]);
          int month = int.parse(dateComponents[1]);
          int year = int.parse(dateComponents[2]);
          int hour = int.parse(timeComponents[0]);
          int minute = int.parse(timeComponents[1]);

          final originalDate = DateTime(year, month, day, hour, minute);
          mDate = DateFormat('MMMM/yyyy').format(originalDate);
        }
      });
    });
  }
  getIncomeData() async {
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(AppConstanst.incomeTransaction)
        .then((value) {
      setState(() {
        incomeTransaction = value;
        for (var item in incomeTransaction) {
          totalIncomeAmount += item.amount ?? 0;
          // Split the date string into its components
          List<String> dateTimeComponents = item.transaction_date!.split(' ');
          List<String> dateComponents = dateTimeComponents[0].split('/');
          List<String> timeComponents = dateTimeComponents[1].split(':');

          // Extract individual components
          int day = int.parse(dateComponents[0]);
          int month = int.parse(dateComponents[1]);
          int year = int.parse(dateComponents[2]);
          int hour = int.parse(timeComponents[0]);
          int minute = int.parse(timeComponents[1]);

          final originalDate = DateTime(year, month, day, hour, minute);
          mDate = DateFormat('MMMM/yyyy').format(originalDate);
        }
      });
    });
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
                        MaterialPageRoute(builder: (context) => SearchScreen()),
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
                            return WillPopScope(
                                onWillPop: () async {
                                  return true;
                                },
                                child: Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: _bottomSheetView(statisticsBloc)));
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
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
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
                  )
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
                child: LineChart(
                  mainData(),
                ),
              ),
            ),
          ),
          15.heightBox,
          if (spendingTransaction.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Helper.getTextColor(context),
                  size: 14,
                ),
                Expanded(
                  child: Text(
                    mDate,
                    style: TextStyle(
                        color: Helper.getTextColor(context), fontSize: 15),
                  ),
                ),
                Text(
                  "\u20B9$totalAmount",
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                )
              ],
            ),
          ),
          10.heightBox,
          if (spendingTransaction.isNotEmpty)
            ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: const BoxDecoration(
                          color: Color(0xff30302d),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.yellow),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.black),
                              child: SvgPicture.asset(
                                'asset/images/${spendingTransaction[index].cat_icon}.svg',
                                color: spendingTransaction[index].cat_color,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          15.widthBox,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spendingTransaction[index].cat_name!,
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 16),
                                ),
                                Text(
                                  spendingTransaction[index].description!,
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "-\u20B9${spendingTransaction[index].amount}",
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 16),
                              ),
                              Text(
                                formatDate(spendingTransaction[index]
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
                itemCount: spendingTransaction.length),
          if (spendingTransaction.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                  decoration: BoxDecoration(
                      color: Helper.getCardColor(context),
                      borderRadius: const BorderRadius.all(Radius.circular(10))),
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
                                  builder: (context) =>
                                      const AddSpendingScreen()),
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
                              style: TextStyle(color: Colors.white, fontSize: 14),
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
          if (incomeTransaction.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Helper.getTextColor(context),
                  size: 14,
                ),
                Expanded(
                  child: Text(
                    mDate,
                    style: TextStyle(
                        color: Helper.getTextColor(context), fontSize: 15),
                  ),
                ),
                Text(
                  "\u20B9$totalIncomeAmount",
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                )
              ],
            ),
          ),
          10.heightBox,

          if (incomeTransaction.isNotEmpty)

            ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: const BoxDecoration(
                          color: Color(0xff30302d),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.yellow),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.black),
                              child: SvgPicture.asset(
                                'asset/images/${spendingTransaction[index].cat_icon}.svg',
                                color: spendingTransaction[index].cat_color,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          15.widthBox,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incomeTransaction[index].cat_name!,
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 16),
                                ),
                                Text(
                                  incomeTransaction[index].description!,
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "+\u20B9${incomeTransaction[index].amount}",
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 16),
                              ),
                              Text(
                                formatDate(incomeTransaction[index]
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
                itemCount: incomeTransaction.length),
          if (incomeTransaction.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                  decoration: BoxDecoration(
                      color: Helper.getCardColor(context),
                      borderRadius: const BorderRadius.all(Radius.circular(10))),
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
                                  builder: (context) =>
                                  const AddSpendingScreen()),
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
                              "Add spending",
                              style: TextStyle(color: Colors.white, fontSize: 14),
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

  _bottomSheetView(StatisticsBloc statisticsBloc) {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
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
                    Text(
                      "Clear filter",
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 16),
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
                        Navigator.pop(context);
                      },
                      child: Text(
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
                child: Text(
                  "YEAR",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Text(
                    "2023",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  "MONTH(Can filter by one or more)",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "January",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "February",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "March",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "April",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "May",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "June",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "July",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "August",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "September",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "October",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "November",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "December",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  "CATEGORY",
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
                    childAspectRatio: 2.2 / 1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gridItemList.length,
                  itemBuilder: (BuildContext context, int index) {
                    GridItem item = gridItemList[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Helper.getCardColor(context),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Text(
                        item.text,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
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

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
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
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
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
}

class GridItem {
  final String text;

  GridItem({required this.text});
}
