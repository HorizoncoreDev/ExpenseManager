import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/overview_screen/add_spending/DateWiseTransactionModel.dart';
import 'package:expense_manager/overview_screen/spending_detail_screen/spending_detail_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  List<DateWiseTransactionModel> dateWiseSpendingTransaction = [];
  List<DateWiseTransactionModel> dateWiseIncomeTransaction = [];
  String userEmail = "";
  int currentBalance = 0;
  int currentIncome = 0;
  int actualBudget = 0;
  int selectedTabIndex = 0;
  bool isSkippedUser = false;
  final databaseHelper = DatabaseHelper();
  ProfileModel profileModel = ProfileModel();

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  getProfileData() async {
    try {
      ProfileModel fetchedProfileData =
      await databaseHelper.getProfileData(userEmail);
      setState(() {
        profileModel = fetchedProfileData;
        currentBalance = int.parse(profileModel.current_balance!);
        currentIncome = int.parse(profileModel.current_income!);
        actualBudget = int.parse(profileModel.actual_budget!);
      });
    } catch (error) {
      print('Error fetching Profile Data: $error');
    }
  }

  getTransactions() async {
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
        if (isSkippedUser) {
          MySharedPreferences.instance
              .getStringValuesSF(
              SharedPreferencesKeys.skippedUserCurrentBalance)
              .then((value) {
            if (value != null) {
              currentBalance = int.parse(value);
            }
          });
          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.skippedUserActualBudget)
              .then((value) {
            if (value != null) {
              actualBudget = int.parse(value);
            }
          });
        } else {
          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.userEmail)
              .then((value) {
            if (value != null) {
              userEmail = value;
              getProfileData();
            }
          });
        }
      }
    });

    List<TransactionModel> spendingTransaction = [];
    dateWiseSpendingTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(AppConstanst.spendingTransaction)
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
      if (dates.isEmpty) {
        if (isSkippedUser) {
          MySharedPreferences.instance.addStringToSF(
              SharedPreferencesKeys.skippedUserCurrentBalance,
              actualBudget.toString());
          currentBalance = actualBudget;
          setState(() {});
        } else {
          currentBalance = actualBudget;
          setState(() {});
          await DatabaseHelper.instance
              .getProfileData(userEmail)
              .then((profileData) async {
            profileData.current_balance = profileData.actual_budget;
            await DatabaseHelper.instance.updateProfileData(profileData);
          });
        }
      } else {
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
        setState(() {});
      }
    });
  }

  getIncomeTransactions() async {
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
        if (isSkippedUser) {
          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.skippedUserCurrentIncome)
              .then((value) {
            if (value != null) {
              currentIncome = int.parse(value);
            }
          });
          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.skippedUserActualBudget)
              .then((value) {
            if (value != null) {
              actualBudget = int.parse(value);
            }
          });
        } else {
          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.userEmail)
              .then((value) {
            if (value != null) {
              userEmail = value;
              getProfileData();
            }
          });
        }
      }
    });

    List<TransactionModel> incomeTransaction = [];
    dateWiseIncomeTransaction = [];
    await DatabaseHelper.instance
        .getTransactions(AppConstanst.incomeTransaction)
        .then((value) async {
      incomeTransaction = value;
      List<String> dates = [];

      DateTime now = DateTime.now();
      String currentMonthName = DateFormat('MMMM').format(now);

      for (var t in incomeTransaction) {
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime parsedDate = format.parse(t.transaction_date!);
        String transactionMonthName = DateFormat('MMMM').format(parsedDate);
        if (transactionMonthName == currentMonthName) {
          if (!dates.contains(t.transaction_date!.split(' ')[0])) {
            dates.add(t.transaction_date!.split(' ')[0]);
          }
        }
      }
      if (dates.isEmpty) {
        if (isSkippedUser) {
          MySharedPreferences.instance.addStringToSF(
              SharedPreferencesKeys.skippedUserCurrentIncome, "0");
          currentIncome = 0;
          setState(() {});
        } else {
          currentIncome = 0;
          setState(() {});
          await DatabaseHelper.instance
              .getProfileData(userEmail)
              .then((profileData) async {
            profileData.current_income = "0";
            await DatabaseHelper.instance.updateProfileData(profileData);
          });
        }
      } else {
        dates.sort((a, b) => b.compareTo(a));
        for (var date in dates) {
          int totalAmount = 0;
          List<TransactionModel> newTransaction = [];
          for (var t in incomeTransaction) {
            if (date == t.transaction_date!.split(' ')[0]) {
              newTransaction.add(t);
              totalAmount = totalAmount + t.amount!;
            } else {
              DateWiseTransactionModel? found =
              dateWiseIncomeTransaction.firstWhereOrNull((element) =>
              element.transactionDate!.split(' ')[0] == date);
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
              transactionDay: Helper.getTransactionDay(date),
              transactions: newTransaction));
        }
        setState(() {});
      }
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "\u20B9${(selectedTabIndex == 0 ? currentBalance : currentIncome).toString()}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          "TODAY, ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Navigator.of(context, rootNavigator: true).push(
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
                                      Navigator.of(context, rootNavigator: true).push(
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
                            TabBar(
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white60,
                              indicatorColor: Colors.white,
                              dividerColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              indicatorPadding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              tabs: const [
                                Tab(child: Text("Spending")),
                                Tab(child: Text("Income")),
                              ],
                              onTap: (index) {
                                selectedTabIndex = index;
                                if (index == 0) {
                                  getTransactions();
                                } else {
                                  getIncomeTransactions();
                                }
                              },
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
                              "\u20B9$actualBudget",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            Text(
                              currentBalance < 0
                                  ? "You are spending over budget!"
                                  : "You are spending on plan!",
                              style: TextStyle(
                                  color: currentBalance < 0
                                      ? Colors.red
                                      : Helper.getTextColor(context),
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
                              currentBalance == actualBudget
                                  ? "\u20B90"
                                  : "\u20B9${(actualBudget - currentBalance).toString()}",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            10.heightBox,
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Helper.getChartColor(context),),
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
                              currentBalance == actualBudget
                                  ? "\u20B9$actualBudget"
                                  : "\u20B9${currentBalance.toString()}",
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
                            sections: showingSpendingSections(),
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
                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
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
                                          style: TextStyle(
                                              color: Helper.getTextColor(context),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          dateWiseSpendingTransaction[index]
                                              .transactions![index1]
                                              .description!,
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
                                        "-\u20B9${dateWiseSpendingTransaction[index].transactions![index1].amount!}",
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${dateWiseSpendingTransaction[index].transactions![index1].payment_method_id == AppConstanst.cashPaymentType ? 'Cash' : ''}/${dateWiseSpendingTransaction[index].transactions![index1].transaction_date!.split(' ')[1]}",
                                        style:  TextStyle(
                                          color: Helper.getTextColor(context),
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
            if (dateWiseSpendingTransaction.isEmpty) 15.heightBox,
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
                              "\u20B9$currentIncome",
                              style: TextStyle(
                                  color: currentIncome < actualBudget
                                      ? Colors.red
                                      : Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            Text(
                              currentIncome >= actualBudget
                                  ? 'Income is same as target'
                                  : "Income is not as expected!",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 12),
                            ),
                            10.heightBox,
                            Text(
                              "Plan",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 12),
                            ),
                            5.heightBox,
                            Text(
                              "\u20B9$actualBudget",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 20),
                            ),
                            10.heightBox,
                            Text(
                              currentIncome>=actualBudget? "More than the Target": "Less than the Target",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 12),
                            ),
                            5.heightBox,
                            Text(
                              currentIncome>=actualBudget?'\u20B9$actualBudget+${currentIncome - actualBudget}':"\u20B9${actualBudget - currentIncome}",
                              style: TextStyle(
                                  color: currentIncome < actualBudget
                                      ? Helper.getChartColor(context)
                                      : Helper.getTextColor(context),
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
                            sections: showingIncomeSections(),
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
            if (dateWiseIncomeTransaction.isNotEmpty) 20.heightBox,
            if (dateWiseIncomeTransaction.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: dateWiseIncomeTransaction.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${dateWiseIncomeTransaction[index].transactionDay}, ${dateWiseIncomeTransaction[index].transactionDate}",
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
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration:  BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration:  const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: SvgPicture.asset(
                                      'asset/images/${dateWiseIncomeTransaction[index].transactions![index1].cat_icon}.svg',
                                      color: dateWiseIncomeTransaction[index]
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
                                          dateWiseIncomeTransaction[index]
                                              .transactions![index1]
                                              .cat_name!,
                                          style:  TextStyle(
                                              color: Helper.getTextColor(context),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          dateWiseIncomeTransaction[index]
                                              .transactions![index1]
                                              .description!,
                                          style:  TextStyle(
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
                                        "+\u20B9${dateWiseIncomeTransaction[index].transactions![index1].amount!}",
                                        style:  TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${dateWiseIncomeTransaction[index].transactions![index1].payment_method_id == AppConstanst.cashPaymentType ? 'Cash' : ''}/${dateWiseIncomeTransaction[index].transactions![index1].transaction_date!.split(' ')[1]}",
                                        style:  TextStyle(
                                          color: Helper.getTextColor(context),
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
            if (dateWiseIncomeTransaction.isEmpty) 10.heightBox,
            if (dateWiseIncomeTransaction.isEmpty)
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
                                  getIncomeTransactions();
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
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSpendingSections() {
    double spendingPercentage =
    currentBalance > 0 ? (currentBalance / actualBudget) * 100 : 100;
    double remainingPercentage =
    currentBalance > 0 ? 100 - spendingPercentage : 0;
    return List.generate(2, (i) {
      const fontSize = 12.0;
      const radius = 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Helper.getChartColor(context),
            value: spendingPercentage.toPrecision(2),
            title: '${spendingPercentage.toPrecision(2)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: remainingPercentage.toPrecision(2),
            title: '${remainingPercentage.toPrecision(2)}%',
            radius: radius,
            titleStyle: const TextStyle(
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

  List<PieChartSectionData> showingIncomeSections() {
    double incomePercentage =
    currentIncome < actualBudget ? (currentIncome / actualBudget) * 100 : 100;
    double remainingPercentage = currentIncome > 0 ? 100 - incomePercentage : 0;
    return List.generate(2, (i) {
      const fontSize = 12.0;
      const radius = 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Helper.getChartColor(context),
            value: remainingPercentage.toPrecision(2) ?? 100,
            title: '${remainingPercentage.toPrecision(2)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: incomePercentage.toPrecision(2),
            title: '${incomePercentage.toPrecision(2)}%',
            radius: radius,
            titleStyle: const TextStyle(
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