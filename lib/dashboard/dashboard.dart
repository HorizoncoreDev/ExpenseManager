import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../overview_screen/add_spending/add_spending_screen.dart';
import '../overview_screen/overview_screen.dart';
import '../statistics/statistics_screen.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool hideNavBar = false;
  String extra = "";
  GlobalKey<OverviewScreenState> overviewKey = GlobalKey<OverviewScreenState>();
  GlobalKey<StatisticsScreenState> overviewKey1 =
      GlobalKey<StatisticsScreenState>();
  String userEmail = "", currentUserEmail = "";
  int currentPage = 0, userAccess = AppConstanst.viewOnlyAccess;
  PageController? pageController;

  @override
  Widget build(BuildContext context) {
    bool currentEmail = userEmail.isNotEmpty
        ? userEmail == currentUserEmail
            ? true
            : userAccess == AppConstanst.editAccess
                ? true
                : false
        : true;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: currentEmail
            ? FloatingActionButton(
                onPressed: () {
                  if (currentEmail) {
                    Navigator.of(context, rootNavigator: true)
                        .push(
                      MaterialPageRoute(
                          builder: (context) => AddSpendingScreen(
                                transactionName: AppConstanst.selectedTabIndex == 0
                                        ? AppConstanst.spendingTransactionName
                                        : AppConstanst.incomeTransactionName,
                              )),
                    ).then((value) {
                      if (value != null) {
                        if (value) {
                          overviewKey.currentState?.getTransactions();
                          overviewKey.currentState?.getIncomeTransactions();
                          overviewKey1.currentState?.getTransactions();
                          overviewKey1.currentState?.getIncomeData();
                          //getTransactions();
                        }
                      }
                    });
                  }
                },
                backgroundColor: Helper.getMiddleBottomNavBarItem(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                child: Icon(
                  Icons.add,
                  color: Helper.getTextColor(context),
                ),
              )
            : const SizedBox(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 60,
          color: Helper.getBottomNavigationColor(context).backgroundColor!,
          shape: const CircularNotchedRectangle(),
          notchMargin: currentEmail ? 5 : 0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    currentPage = 0;
                    _jumpToPage(currentPage);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.home,
                        color: currentPage == 0
                            ? Helper.getBottomNavigationColor(context)
                                .selectedItemColor!
                            : Helper.getBottomNavigationColor(context)
                                .unselectedItemColor!,
                      ),
                      Text(
                        LocaleKeys.overview.tr,
                        style: TextStyle(
                          color: currentPage == 0
                              ? Helper.getBottomNavigationColor(context)
                                  .selectedItemColor!
                              : Helper.getBottomNavigationColor(context)
                                  .unselectedItemColor!,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    currentPage = 2;
                    _jumpToPage(currentPage);
                  },


                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stacked_bar_chart,
                        color: currentPage == 2
                            ? Helper.getBottomNavigationColor(context)
                                .selectedItemColor!
                            : Helper.getBottomNavigationColor(context)
                                .unselectedItemColor!,
                      ),
                      Text(
                        LocaleKeys.statistics.tr,
                        style: TextStyle(
                          color: currentPage == 2
                              ? Helper.getBottomNavigationColor(context)
                                  .selectedItemColor!
                              : Helper.getBottomNavigationColor(context)
                                  .unselectedItemColor!,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: buildScreens(),
        ),
      ),
    );
  }

  List<Widget> buildScreens() {
    return [
      OverviewScreen(key: overviewKey, onAccountUpdate: updateBottomSheet),
      const SizedBox(),
      StatisticsScreen(key: overviewKey1),
    ];
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPage);
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isCategoriesAdded)
        .then((value) {
      if (value != null) {
        if (!value) {
          Helper.addDefaultCategories().then((value) => MySharedPreferences
              .instance
              .addBoolToSF(SharedPreferencesKeys.isCategoriesAdded, true));
        }
      } else {
        Helper.addDefaultCategories().then((value) => MySharedPreferences
            .instance
            .addBoolToSF(SharedPreferencesKeys.isCategoriesAdded, true));
      }
    });
    updateBottomSheet();

    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currencySymbol)
        .then((value) {
      if (value != null) {
        AppConstanst.currencySymbol = value;
        print("CS --- ${AppConstanst.currencySymbol}");
      }
    });

    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.languageCode)
        .then((value) {
      if (value != null) {
        AppConstanst.languageCode = value;
        print("LC --- ${AppConstanst.languageCode}");
      }
    });

    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currencyCode)
        .then((value) {
      if (value != null) {
        AppConstanst.currencyCode = value;
        print("CC --- ${AppConstanst.currencyCode}");
      }
    });
  }

  updateBottomSheet() {
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
            setState(() {});
            MySharedPreferences.instance
                .getIntValuesSF(SharedPreferencesKeys.userAccessType)
                .then((value) {
              if (value != null) {
                userAccess = value;
             /*   MySharedPreferences.instance
                    .getStringValuesSF(
                    SharedPreferencesKeys
                        .currentAccountKey)
                    .then((value) {
                  if (value != null) {
                    currentAccountKey = value;
                  }
                });*/
                setState(() {});
              }
            });
          }
        });
      }
    });
  }

  void _jumpToPage(int page) {
    if (pageController!.hasClients) {
      pageController!.jumpToPage(page);
      setState(() {});
    }
  }
}
