import 'package:expense_manager/overview_screen/spending_detail_screen/spending_detail_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../other_screen/other_screen.dart';
import '../statistics/search/search_screen.dart';
import '../utils/theme_notifier.dart';
import 'add_spending/add_spending_screen.dart';
import 'bloc/overview_bloc.dart';
import 'bloc/overview_state.dart';
import 'income_detail_screen/income_detail_screen.dart';
import 'package:provider/provider.dart';


class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {

  OverviewBloc overviewBloc = OverviewBloc();

  @override
  Widget build(BuildContext context) {
    overviewBloc.context = context;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return BlocConsumer<OverviewBloc, OverviewState>(
      bloc: overviewBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is OverviewInitial){
          return SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                body: Container(
                  color: themeNotifier.getTheme().backgroundColor,
                  height: double.infinity,
                  child: Stack(
                        children: [
                          Container(
                            height: 250,
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(50))
                            ),
                          ),
                          Column(
                            children: [
                              20.heightBox,
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal:20),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("-\u20B932,781.78",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20
                                            ),),
                                          Text("TODAY, 03/10/2023",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13
                                            ),)
                                        ],
                                      ),
                                    ),

                                    InkWell(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SearchScreen()),
                                          );
                                        },
                                        child: const Icon(Icons.search,color: Colors.white,size: 28,)),
                                    10.widthBox,
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const OtherScreen()),
                                        );
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white
                                          ),
                                          child: const Icon(Icons.family_restroom,color: Colors.blue,size: 28,)),
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
                      )
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
                  decoration: const BoxDecoration(
                      color: Color(0xff30302d),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10,top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("\u20B928,700",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20
                            ),),
                            const Text("You are spending on plan!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12
                              ),),

                            10.heightBox,
                            Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue
                                    ),
                                ),
                                5.widthBox,
                                const Text("Spent",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12
                                  ),),
                              ],
                            ),
                            5.heightBox,
                            const Text("\u20B928,700",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),),

                            10.heightBox,
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow
                                  ),
                                ),
                                5.widthBox,
                                const Text("Remaining",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12
                                  ),),
                              ],
                            ),
                            5.heightBox,
                            const Text("\u20B926,604",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),),
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
    onTap: (){
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SpendingDetailScreen()),
    );},
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topLeft: Radius.circular(5))
                        ),
                        child: const Icon(Icons.arrow_forward,size: 18,),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /*20.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TODAY, 03/10/2023",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14
                ),),
                Text("-\u20B928,700",
                  style: TextStyle(
                      color: Colors.pink,
                      fontSize: 14
                  ),),
              ],
            ),*/

            15.heightBox,
           /* Container(
              padding: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(0xff30302d),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Icon(Icons.cake,color: Colors.blue,),
                  ),
                  15.widthBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dine out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),),
                        Text("Bbb",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                          ),)
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("-\u20B92,096",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),),
                      Text("Cash/16:11",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),)
                    ],
                  )
                ],
              ),
            ),*/

            Container(
              decoration: const BoxDecoration(
                  color: Color(0xff30302d),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Column(
                children: [
                  20.heightBox,
                  const Icon(Icons.account_balance_wallet,color: Colors.white,size: 80,),
                  10.heightBox,
                  const Text("You don't have any expenses yet",
                  style: TextStyle(
                    color: Colors.grey
                  ),),
                  20.heightBox,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: InkWell(
                      onTap: (){
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => const AddSpendingScreen()),);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child:  const Text("Add spending",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14
                          ),),
                      ),
                    ),
                  ),
                  15.heightBox,
                ],
              )
            ),

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
                  decoration: const BoxDecoration(
                      color: Color(0xff30302d),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10,top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("\u20B928,700",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),),
                            const Text("You are spending on plan!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12
                              ),),

                            10.heightBox,
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue
                                  ),
                                ),
                                5.widthBox,
                                const Text("Spent",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12
                                  ),),
                              ],
                            ),
                            5.heightBox,
                            const Text("\u20B928,700",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),),

                            10.heightBox,
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow
                                  ),
                                ),
                                5.widthBox,
                                const Text("Remaining",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12
                                  ),),
                              ],
                            ),
                            5.heightBox,
                            const Text("\u20B926,604",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),),
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
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IncomeDetailScreen()),
                        );},
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topLeft: Radius.circular(5))
                        ),
                        child: const Icon(Icons.arrow_forward,size: 18,),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            20.heightBox,
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TODAY, 03/10/2023",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),),
                Text("-\u20B928,700",
                  style: TextStyle(
                      color: Colors.pink,
                      fontSize: 14
                  ),),
              ],
            ),

            10.heightBox,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(0xff30302d),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: const Icon(Icons.cake,color: Colors.blue,),
                  ),
                  15.widthBox,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dine out",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),),
                        Text("Bbb",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),)
                      ],
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("-\u20B92,096",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),),
                      Text("Cash/16:11",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),)
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
      final fontSize =  12.0;
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
