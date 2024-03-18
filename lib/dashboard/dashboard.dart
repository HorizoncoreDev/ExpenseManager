import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:flutter/material.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../overview_screen/add_spending/add_spending_screen.dart';
import '../overview_screen/overview_screen.dart';
import '../statistics/statistics_screen.dart';
import '../utils/helper.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
//  late BuildContext context;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentTabController controller =
  PersistentTabController(initialIndex: 0);
  bool hideNavBar = false;


  List<Widget> buildScreens() {
    return [
      const OverviewScreen(),
      const AddSpendingScreen(),
      const StatisticsScreen(),
    ];
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
                backgroundColor: Helper.getBackgroundColor(context),
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                stateManagement: true,
                navBarHeight: kBottomNavigationBarHeight,
                hideNavigationBarWhenKeyboardShows: true,
                margin: EdgeInsets.zero,
                popActionScreens: PopActionScreensType.all,
                //bottomScreenMargin: 50,
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
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.white70,
        inactiveColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add),
        contentPadding: 0,
        activeColorPrimary: Colors.blue,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.white,
         ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: ("Statistics"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.white70,
      ),
    ];
  }

}