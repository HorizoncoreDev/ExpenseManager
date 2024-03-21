import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
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
//  late BuildContext context;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentTabController controller = PersistentTabController(initialIndex: 0);
  bool hideNavBar = false;
  GlobalKey<OverviewScreenState> overviewKey = GlobalKey<OverviewScreenState>();
  GlobalKey<StatisticsScreenState> overviewKey1 = GlobalKey<StatisticsScreenState>();

  List<Widget> buildScreens() {
    return [
       OverviewScreen(key: overviewKey,),
      Container(),
      StatisticsScreen(key: overviewKey1),
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
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
        icon: Icon(Icons.home),
        title: "Overview",
        activeColorPrimary:
            Helper.getBottomNavigationColor(context).selectedItemColor!,
        inactiveColorPrimary:
            Helper.getBottomNavigationColor(context).unselectedItemColor!,
        inactiveColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
          icon: const Icon(Icons.add),
          contentPadding: 0,
          activeColorPrimary: Helper.getMiddleBottomNavBarItem(context),
          activeColorSecondary: Helper.getTextColor(context),
          inactiveColorPrimary: Helper.getTextColor(context),
          inactiveColorSecondary: Helper.getTextColor(context),
          onPressed: (contet){
            Navigator.of(context, rootNavigator: true).
            push(MaterialPageRoute(builder: (context) => const AddSpendingScreen()),).then((value) {

              if(value!=null){
                if(value){
                  overviewKey.currentState?.getTransactions();
                  overviewKey1.currentState?.getTransactions();
                  overviewKey1.currentState?.getIncomeData();
                  //getTransactions();
                }
              }
            });
          }),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: ("Statistics"),
        activeColorPrimary:
            Helper.getBottomNavigationColor(context).selectedItemColor!,
        inactiveColorPrimary:
            Helper.getBottomNavigationColor(context).unselectedItemColor!,
      ),
    ];
  }
}
