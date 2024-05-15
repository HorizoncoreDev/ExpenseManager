import 'dart:convert';

import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/overview_screen/add_spending/DateWiseTransactionModel.dart';
import 'package:expense_manager/overview_screen/spending_detail_screen/spending_detail_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../db_models/request_model.dart';
import '../db_models/transaction_model.dart';
import '../other_screen/other_screen.dart';
import '../statistics/search/search_screen.dart';
import 'add_spending/add_spending_screen.dart';
import 'bloc/overview_bloc.dart';
import 'bloc/overview_state.dart';
import 'edit_spending/edit_spending_screen.dart';
import 'income_detail_screen/income_detail_screen.dart';

class OverviewScreen extends StatefulWidget {
  final VoidCallback onAccountUpdate;

  const OverviewScreen({super.key, required this.onAccountUpdate});

  @override
  State<OverviewScreen> createState() => OverviewScreenState();
}

class OverviewScreenState extends State<OverviewScreen> {
  OverviewBloc overviewBloc = OverviewBloc();
  List<DateWiseTransactionModel> dateWiseSpendingTransaction = [];
  List<DateWiseTransactionModel> dateWiseIncomeTransaction = [];
  String currentUserEmail = "";
  String currentUserKey = "";
  String userEmail = "";
  String? userName;
  int currentBalance = 0;
  int currentIncome = 0;
  int actualBudget = 0;
  bool isSkippedUser = false, loading = true;
  final databaseHelper = DatabaseHelper();
  ProfileModel profileModel = ProfileModel();
  List<TransactionModel> spendingTransaction = [];

  @override
  void initState() {
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) async {
      if (value != null) {
        isSkippedUser = value;
        if (isSkippedUser) {
          getTransactions();
        } else {
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
                      .getStringValuesSF(SharedPreferencesKeys.currentUserKey)
                      .then((value) {
                    if (value != null) {
                      currentUserKey = value;
                      MySharedPreferences.instance
                          .getStringValuesSF(SharedPreferencesKeys.currentUserName)
                          .then((value) {
                        if (value != null) {
                          userName = value;
                          getTransactions();
                        }
                      }); }
                  });
                }
              });
            }
          });
        }
      }
    });

    super.initState();
  }

  void checkRequests() {
    final reference = FirebaseDatabase.instance
        .reference()
        .child(request_table)
        .orderByChild('receiver_email')
        .equalTo(profileModel.email);

    reference.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
        dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          if (value['status'] == AppConstanst.pendingRequest) {
            RequestModel requestModel = RequestModel(
                key: key,
                requester_email: value['requester_email'],
                requester_name: value['requester_name'],
                receiver_email: value['receiver_email'],
                receiver_name: value['receiver_name'],
                status: value['status'],
                created_at: value['created_at']);
            sendRequestNotification(requestModel, profileModel);
          }
        });
      }
    });
  }

  void sendRequestNotification(
      RequestModel requesterModel, ProfileModel profileModel) async {
    final reference = FirebaseDatabase.instance
        .reference()
        .child(profile_table)
        .orderByChild('email')
        .equalTo(requesterModel.receiver_email);

    reference.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
        dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) async {
          await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
              'key=AAAANkNYKio:APA91bHGQs2MllIVYtH83Lunknc7v8dXwEPlaqNKpM5u6oHIx3kNYU2VFNuYpEyVzg3hqWjoR-WzWiWMmDN8RrO1QwzEqIrGST726TgPxkp87lqbEI515NzGt7HYdCbrljuH0uldBCW8'
            },
            body: jsonEncode({
              'to': value['fcm_token'],
              'priority': 'high',
              'notification': {
                'title': 'Hello ${requesterModel.receiver_name},',
                'body':
                'You have a new request from ${requesterModel.requester_name}',
              },
            }),
          );
        });
      }
    });
  }

  getProfileData() async {
    try {
      if(currentUserEmail==userEmail) {
        ProfileModel? fetchedProfileData =
        await databaseHelper.getProfileData(currentUserEmail);
        setState(() {
          profileModel = fetchedProfileData!;
          currentBalance = int.parse(profileModel.current_balance!);
          currentIncome = int.parse(profileModel.current_income!);
          actualBudget = int.parse(profileModel.actual_budget!);
          checkRequests();
        });
      }else{
        final reference = FirebaseDatabase.instance
            .reference()
            .child(profile_table)
            .orderByChild(ProfileTableFields.email)
            .equalTo(currentUserEmail);

        reference.onValue.listen((event) {
          DataSnapshot dataSnapshot = event.snapshot;
          if (event.snapshot.exists) {
            Map<dynamic, dynamic> values =
            dataSnapshot.value as Map<dynamic, dynamic>;
            values.forEach((key, value) async {
              profileModel = ProfileModel.fromMap(value);
              currentBalance = int.parse(profileModel.current_balance!);
              currentIncome = int.parse(profileModel.current_income!);
              actualBudget = int.parse(profileModel.actual_budget!);
            });
          }
        });
      }
    } catch (error) {
      print('Error fetching Profile Data: $error');
    }
  }

  getTransactions() async {
    if (isSkippedUser) {
      MySharedPreferences.instance
          .getStringValuesSF(SharedPreferencesKeys.skippedUserCurrentBalance)
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
      getProfileData();
    }

    spendingTransaction = [];
    dateWiseSpendingTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(
        AppConstanst.spendingTransaction, currentUserEmail,currentUserKey, isSkippedUser)
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
        if (!isSkippedUser) {
          if (t.member_email == "") {
            // t.member_id = profileModel.id;
            t.member_email = profileModel.email;
            await databaseHelper.updateTransaction(t);
          }
        }
      }

      if (dates.isEmpty) {
        if (isSkippedUser) {
          MySharedPreferences.instance.addStringToSF(
              SharedPreferencesKeys.skippedUserCurrentBalance,
              actualBudget.toString());
          currentBalance = actualBudget;
          setState(() {
            loading = false;
          });
        } else {
          currentBalance = actualBudget;
          setState(() {
            loading = false;
          });
          if(currentUserEmail==userEmail) {
            await DatabaseHelper.instance
                .getProfileData(currentUserEmail)
                .then((profileData) async {
              profileData!.current_balance = profileData.actual_budget;
              await DatabaseHelper.instance.updateProfileData(profileData);
            });
          }
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
        setState(() {
          loading = false;
        });
      }
    });
  }

  getIncomeTransactions() async {
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
    }
    else {
      getProfileData();
    }

    List<TransactionModel> incomeTransaction = [];
    dateWiseIncomeTransaction = [];
    await DatabaseHelper.instance
        .fetchDataForCurrentMonth(
        AppConstanst.incomeTransaction, currentUserEmail,currentUserKey, isSkippedUser)
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
          if(userEmail == currentUserEmail) {
            await DatabaseHelper.instance
                .getProfileData(currentUserEmail)
                .then((profileData) async {
              profileData!.current_income = "0";
              await DatabaseHelper.instance.updateProfileData(profileData);
            });
          }
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
          return PopScope(
            canPop: true,
            child: SafeArea(
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
                                            "${userName ?? 'Guest'}: \u20B9${(AppConstanst.selectedTabIndex == 0 ? currentBalance : currentIncome).toString()}",
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
                                          Navigator.of(context,
                                              rootNavigator: true)
                                              .push(
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
                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const OtherScreen()),
                                        )
                                            .then((value) {
                                          widget.onAccountUpdate();
                                          MySharedPreferences.instance
                                              .getStringValuesSF(
                                              SharedPreferencesKeys
                                                  .currentUserKey)
                                              .then((value) {
                                            if (value != null) {
                                              currentUserKey = value;
                                              MySharedPreferences.instance
                                                  .getStringValuesSF(
                                                  SharedPreferencesKeys
                                                      .currentUserEmail)
                                                  .then((value) {
                                                if (value != null) {
                                                  currentUserEmail = value;
                                                  MySharedPreferences.instance
                                                      .getStringValuesSF(
                                                      SharedPreferencesKeys
                                                          .currentUserName)
                                                      .then((value) {
                                                    if (value != null) {
                                                      userName = value;
                                                      getTransactions();
                                                    }
                                                  }); }
                                              });
                                            }
                                          });
                                        });
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
                                  setState(() {
                                    loading = true;
                                  });
                                  AppConstanst.selectedTabIndex = index;
                                  if (index == 0) {
                                    getTransactions();
                                  } else {
                                    getIncomeTransactions();
                                  }
                                },
                              ),
                              Expanded(
                                child: TabBarView(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
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
                                    color: Helper.getChartColor(context),
                                  ),
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
                        Navigator.of(context, rootNavigator: true).push(
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
            if (loading) 100.heightBox,
            if (loading)
              const CircularProgressIndicator(
                color: Colors.blue,
              ),
            if (dateWiseSpendingTransaction.isNotEmpty && !loading)
              ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: dateWiseSpendingTransaction.length,
                itemBuilder: (context, index) {
                  if (dateWiseSpendingTransaction.isNotEmpty &&
                      dateWiseSpendingTransaction[index]
                          .transactions!
                          .isNotEmpty) {
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
                              final transaction =
                              dateWiseSpendingTransaction[index]
                                  .transactions![index1];
                              return AbsorbPointer(
                                absorbing: userEmail != currentUserEmail,
                                child: Dismissible(
                                  key: Key(transaction.key!),
                                  // Unique key for each item
                                  direction: DismissDirection.endToStart,
                                  // Allow swiping from right to left
                                  background: Container(),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    alignment: Alignment.centerRight,
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text(
                                              "Are you sure you want to delete this transaction?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: (direction) async {
                                    setState(() {
                                      dateWiseSpendingTransaction[index]
                                          .transactions!
                                          .removeAt(index1);
                                    });
                                    await databaseHelper.deleteTransactionFromDB(
                                        transaction, isSkippedUser);

                                    setState(() {
                                      currentBalance =
                                          currentBalance + transaction.amount!;
                                    });
                                    await DatabaseHelper.instance
                                        .getProfileData(currentUserEmail)
                                        .then((profileData) async {
                                      profileData!.current_balance =
                                          currentBalance.toString();
                                      await DatabaseHelper.instance
                                          .updateProfileData(profileData);

                                      getTransactions();
                                    });
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      if (userEmail == currentUserEmail) {
                                        Navigator.of(context, rootNavigator: true)
                                            .push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditSpendingScreen(
                                                    transactionModel: transaction,
                                                  )),
                                        )
                                            .then((value) {
                                          if (value != null) {
                                            if (value) {
                                              getTransactions();
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
                                            Radius.circular(10)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            child: SvgPicture.asset(
                                              'asset/images/${transaction.cat_icon}.svg',
                                              color: transaction.cat_color,
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  transaction.cat_name!,
                                                  style: TextStyle(
                                                    color: Helper.getTextColor(
                                                        context),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  transaction.description!,
                                                  style: TextStyle(
                                                    color: Helper.getTextColor(
                                                        context),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "-\u20B9${transaction.amount!}",
                                                style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                transaction.payment_method_name!,
                                                style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 10);
                            },
                          ),
                      ],
                    );
                  }
                  return null;
                },
                separatorBuilder: (BuildContext context, int index) {
                  return 10.heightBox;
                },
              ),
            if (dateWiseSpendingTransaction.isEmpty) 15.heightBox,
            if (dateWiseSpendingTransaction.isEmpty && !loading)
              Container(
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
                        "You don't have any expenses yet",
                        style: TextStyle(color: Helper.getTextColor(context)),
                      ),
                      20.heightBox,
                      if (userEmail == currentUserEmail)
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
                              currentIncome >= actualBudget
                                  ? "More than the Target"
                                  : "Less than the Target",
                              style: TextStyle(
                                  color: Helper.getTextColor(context),
                                  fontSize: 12),
                            ),
                            5.heightBox,
                            Text(
                              currentIncome >= actualBudget
                                  ? '\u20B9$actualBudget+${currentIncome - actualBudget}'
                                  : "\u20B9${actualBudget - currentIncome}",
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
                        Navigator.of(context, rootNavigator: true).push(
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
                  if (dateWiseIncomeTransaction[index]
                      .transactions!
                      .isNotEmpty) {
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
                              final transaction =
                              dateWiseIncomeTransaction[index]
                                  .transactions![index1];
                              return AbsorbPointer(
                                absorbing: userEmail != currentUserEmail,
                                child: Dismissible(
                                  key: Key(transaction.key!),
                                  direction: DismissDirection.endToStart,
                                  background: Container(),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    alignment: Alignment.centerRight,
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text(
                                              "Are you sure you want to delete this transaction?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(true),
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: (direction) async {
                                    setState(() {
                                      dateWiseIncomeTransaction[index]
                                          .transactions!
                                          .removeAt(index1);
                                    });
                                    await databaseHelper.deleteTransactionFromDB(
                                        transaction, isSkippedUser);

                                    setState(() {
                                      currentIncome =
                                          currentIncome - transaction.amount!;
                                    });
                                    await DatabaseHelper.instance
                                        .getProfileData(currentUserEmail)
                                        .then((profileData) async {
                                      profileData!.current_income =
                                          currentIncome.toString();
                                      await DatabaseHelper.instance
                                          .updateProfileData(profileData);

                                      getIncomeTransactions();
                                    });
                                  },

                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditSpendingScreen(
                                                  transactionModel: transaction,
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
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Helper.getCardColor(context),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            child: SvgPicture.asset(
                                              'asset/images/${transaction.cat_icon}.svg',
                                              color: transaction.cat_color,
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  transaction.cat_name!,
                                                  style: TextStyle(
                                                    color: Helper.getTextColor(
                                                        context),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  transaction.description!,
                                                  style: TextStyle(
                                                    color: Helper.getTextColor(
                                                        context),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "+\u20B9${transaction.amount!}",
                                                style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                transaction.payment_method_name!,
                                                style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 10);
                            },
                          ),
                      ],
                    );
                  }
                  return null;
                },
                separatorBuilder: (BuildContext context, int index) {
                  return 10.heightBox;
                },
              ),
            if (dateWiseIncomeTransaction.isEmpty) 10.heightBox,
            if (dateWiseIncomeTransaction.isEmpty)
              Container(
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
                        "You don't have any income yet",
                        style: TextStyle(color: Helper.getTextColor(context)),
                      ),
                      20.heightBox,
                      if (userEmail == currentUserEmail)
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
      const shadows = [Shadow(color: Colors.black, blurRadius: 1)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Helper.getChartColor(context),
            value: spendingPercentage.toPrecision(2),
            title: '${spendingPercentage.toPrecision(2)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              color: Colors.black,
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
              color: Colors.black,
              shadows: shadows,
            ),
          );

        default:
          throw Error();
      }
    });
  }

  List<PieChartSectionData> showingIncomeSections() {
    double incomePercentage = currentIncome < actualBudget
        ? (currentIncome / actualBudget) * 100
        : 100;
    double remainingPercentage =
    currentIncome > 0 ? 100 - incomePercentage : 100;
    return List.generate(2, (i) {
      const fontSize = 12.0;
      const radius = 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 1)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Helper.getChartColor(context),
            value: remainingPercentage.toPrecision(2) ?? 100,
            title: '${remainingPercentage.toPrecision(2)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              color: Colors.black,
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
              color: Colors.black,
              shadows: shadows,
            ),
          );

        default:
          throw Error();
      }
    });
  }
}
