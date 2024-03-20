import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/overview_screen/add_spending/DateWiseTransactionModel.dart';
import 'package:expense_manager/overview_screen/spending_detail_screen/spending_detail_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../db_models/transaction_model.dart';
import '../other_screen/other_screen.dart';
import '../statistics/search/search_screen.dart';
import 'add_spending/add_spending_screen.dart';
import 'bloc/overview_bloc.dart';
import 'bloc/overview_state.dart';
import 'income_detail_screen/income_detail_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => OverviewScreenState();
}

class OverviewScreenState extends State<OverviewScreen> {
  OverviewBloc overviewBloc = OverviewBloc();
  List<TransactionModel> spendingTransaction = [];
  List<DateWiseTransactionModel> dateWiseSpendingTransaction = [];

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  getTransactions() async {
    await DatabaseHelper.instance
        .getTransactions(AppConstanst.spendingTransaction)
        .then((value) {
      setState(() {
        spendingTransaction = value;
        List<String> dates = [];
        for (var t in spendingTransaction) {
          if (!dates.contains(t.transaction_date!.split(' ')[0])) {
            dates.add(t.transaction_date!.split(' ')[0]);
          }
        }
        dates.sort((a, b) => b.compareTo(a));

        for (var date in dates) {
          int totalAmount = 0;
          List<TransactionModel> newTransaction = [];
          for (var t in spendingTransaction) {
            if (date == t.transaction_date!.split(' ')[0]) {
              newTransaction.add(t);
              totalAmount = totalAmount + t.amount!;
            } else {
              DateWiseTransactionModel? found =
                  dateWiseSpendingTransaction.firstWhereOrNull((element) =>
                      element.transactionDate!.split(' ')[0] == date);
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
              transactionDay: Helper.getTransactionDay(date),
              transactions: newTransaction));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    overviewBloc.context = context;
    return BlocConsumer<OverviewBloc, OverviewState>(
      bloc: overviewBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is OverviewInitial) {
          return SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                body: Container(
                    color: Helper.getBackgroundColor(context),
                    height: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          height: 250,
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(50))),
                        ),
                        Column(
                          children: [
                            20.heightBox,
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "-\u20B932,781.78",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          "TODAY, 03/10/2023",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SearchScreen()),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 28,
                                      )),
                                  10.widthBox,
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const OtherScreen()),
                                      );
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white),
                                        child: const Icon(
                                          Icons.family_restroom,
                                          color: Colors.blue,
                                          size: 28,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const TabBar(
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white60,
                              indicatorColor: Colors.white,
                              dividerColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              indicatorPadding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              tabs: [
                                Tab(child: Text("Spending")),
                                Tab(child: Text("Income")),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _spendingView(overviewBloc),
                                    _incomeView(overviewBloc)
                                  ]),
                            ),
                            30.heightBox,
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _spendingView(OverviewBloc overviewBloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SingleChildScrollView(
        child: Column(
          children: [
            10.heightBox,
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Helper.getCardColor(context),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "\u20B928,700",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            Text(
                              "You are spending on plan!",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 12),
                            ),
                            10.heightBox,
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue),
                                ),
                                5.widthBox,
                                Text(
                                  "Spent",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            5.heightBox,
                            Text(
                              "\u20B928,700",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            10.heightBox,
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
                                  "Remaining",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            5.heightBox,
                            Text(
                              "\u20B926,604",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            5.heightBox
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4.5,
                        width: MediaQuery.of(context).size.width / 2.4,
                        child: PieChart(
                          PieChartData(
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: showingSections(),
                          ),
                        ),
                      ),
                      5.widthBox
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SpendingDetailScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topLeft: Radius.circular(5))),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (dateWiseSpendingTransaction.isNotEmpty) 20.heightBox,
            if (dateWiseSpendingTransaction.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: dateWiseSpendingTransaction.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${dateWiseSpendingTransaction[index].transactionDay}, ${dateWiseSpendingTransaction[index].transactionDate}",
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

                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: Color(0xff30302d),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: SvgPicture.asset(
                                      'asset/images/${dateWiseSpendingTransaction[index].transactions![index1].cat_icon}.svg',
                                      color: dateWiseSpendingTransaction[index]
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
                                          dateWiseSpendingTransaction[index]
                                              .transactions![index1]
                                              .cat_name!,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          dateWiseSpendingTransaction[index]
                                              .transactions![index1]
                                              .description!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "-\u20B9${dateWiseSpendingTransaction[index].transactions![index1].amount!}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${dateWiseSpendingTransaction[index].transactions![index1].payment_method_id == AppConstanst.cashPaymentType ? 'Cash' : ''}/${dateWiseSpendingTransaction[index].transactions![index1].transaction_date!.split(' ')[1]}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  )
                                ],
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
            if (dateWiseSpendingTransaction.isEmpty)
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
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
    );
  }

  Widget _incomeView(OverviewBloc overviewBloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SingleChildScrollView(
        child: Column(
          children: [
            10.heightBox,
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Helper.getCardColor(context),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "\u20B928,700",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            Text(
                              "You are spending on plan!",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 12),
                            ),
                            10.heightBox,
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue),
                                ),
                                5.widthBox,
                                Text(
                                  "Spent",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            5.heightBox,
                            Text(
                              "\u20B928,700",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            10.heightBox,
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
                                  "Remaining",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            5.heightBox,
                            Text(
                              "\u20B926,604",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            5.heightBox
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4.5,
                        width: MediaQuery.of(context).size.width / 2.4,
                        child: PieChart(
                          PieChartData(
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: showingSections(),
                          ),
                        ),
                      ),
                      5.widthBox
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const IncomeDetailScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topLeft: Radius.circular(5))),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            20.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TODAY, 03/10/2023",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
                const Text(
                  "-\u20B928,700",
                  style: TextStyle(color: Colors.pink, fontSize: 14),
                ),
              ],
            ),
            10.heightBox,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Helper.getCardColor(context),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: const Icon(
                      Icons.cake,
                      color: Colors.blue,
                    ),
                  ),
                  15.widthBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dine out",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Bbb",
                          style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "-\u20B92,096",
                        style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Cash/16:11",
                        style: TextStyle(
                          color: Helper.getTextColor(context),
                          fontSize: 14,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final fontSize = 12.0;
      final radius = 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xffc4c45e),
            value: 92.7,
            title: '92.7%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: 7.3,
            title: '7.3%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );

        default:
          throw Error();
      }
    });
  }
}
