import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

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
  PersistentTabController controller = PersistentTabController(initialIndex: 0);
  bool hideNavBar = false;
  GlobalKey<OverviewScreenState> overviewKey = GlobalKey<OverviewScreenState>();
  GlobalKey<StatisticsScreenState> overviewKey1 =
      GlobalKey<StatisticsScreenState>();
  String userEmail = "", currentUserEmail = "";

  List<Widget> buildScreens() {
    return [
      OverviewScreen(key: overviewKey, onAccountUpdate: updateBottomSheet),
      SizedBox(),
      StatisticsScreen(key: overviewKey1),
    ];
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
          }
        });
      }
    });
  }

  @override
  void initState() {
    print(Get.locale!.languageCode);
    super.initState();
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
        print("CS --- ${AppConstanst.languageCode}");
      }
    });

    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.currencyCode)
        .then((value) {
      if (value != null) {
        AppConstanst.currencyCode = value;
        print("CS --- ${AppConstanst.currencyCode}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        bottomNavigationBar: PersistentTabView(
          context,
          controller: controller,
          screens: buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor:
              Helper.getBottomNavigationColor(context).backgroundColor!,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          navBarHeight: kBottomNavigationBarHeight,
          hideNavigationBarWhenKeyboardShows: true,
          margin: EdgeInsets.zero,
          popActionScreens: PopActionScreensType.all,
          // bottomScreenMargin: 50,
          hideNavigationBar: hideNavBar,
          popAllScreensOnTapOfSelectedTab: true,
          navBarStyle: NavBarStyle.style15,
        ),
      ),
    );
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: LocaleKeys.overview.tr,
        activeColorPrimary:
            Helper.getBottomNavigationColor(context).selectedItemColor!,
        inactiveColorPrimary:
            Helper.getBottomNavigationColor(context).unselectedItemColor!,
        inactiveColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
          icon: userEmail!.isNotEmpty
              ? userEmail == currentUserEmail
                  ? const Icon(Icons.add)
                  : const SizedBox()
              : const Icon(Icons.add),
          contentPadding: 0,
          activeColorPrimary: userEmail!.isNotEmpty
              ? userEmail == currentUserEmail
                  ? Helper.getMiddleBottomNavBarItem(context)
                  : Colors.transparent
              : Helper.getMiddleBottomNavBarItem(context),
          activeColorSecondary: Helper.getTextColor(context),
          inactiveColorPrimary: Helper.getTextColor(context),
          inactiveColorSecondary: Helper.getTextColor(context),
          onPressed: (contet) {
            if (userEmail == currentUserEmail || userEmail!.isEmpty) {
              Navigator.of(context, rootNavigator: true)
                  .push(
                MaterialPageRoute(
                    builder: (context) => AddSpendingScreen(
                          transactionName: AppConstanst.selectedTabIndex == 0
                              ? AppConstanst.spendingTransactionName
                              : AppConstanst.incomeTransactionName,
                        )),
              )
                  .then((value) {
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
          }),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: (LocaleKeys.statistics.tr),
        activeColorPrimary:
            Helper.getBottomNavigationColor(context).selectedItemColor!,
        inactiveColorPrimary:
            Helper.getBottomNavigationColor(context).unselectedItemColor!,
      ),
    ];
  }
}
