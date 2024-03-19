import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/theme_notifier.dart';
import '../../utils/views/custom_text_form_field.dart';
import 'bloc/income_detail_bloc.dart';
import 'bloc/income_detail_state.dart';

class IncomeDetailScreen extends StatefulWidget {
  const IncomeDetailScreen({super.key});

  @override
  State<IncomeDetailScreen> createState() => _IncomeDetailScreenState();
}

class _IncomeDetailScreenState extends State<IncomeDetailScreen> {

  IncomeDetailBloc incomeDetailBloc = IncomeDetailBloc();
  TextEditingController searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    incomeDetailBloc.context = context;

    return BlocConsumer<IncomeDetailBloc, IncomeDetailState>(
      bloc: incomeDetailBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is IncomeDetailInitial){
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor:Helper.getBackgroundColor(context),
                title: Row(
                  children: [
                    InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios,color: Helper.getTextColor(context),size: 20,)),
                    10.widthBox,
                    Text("1/2024",
                        style: TextStyle(
                          fontSize: 22,
                          color: Helper.getTextColor(context),)),
                    Text(" /\u20B9798,136.33",
                        style: TextStyle(
                          fontSize: 18,
                          color: Helper.getTextColor(context),)),
                  ],
                ),
                actions: [
                  InkWell(
                    onTap: (){
                      showModalBottomSheet<void>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          clipBehavior:
                          Clip.antiAliasWithSaveLayer,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return WillPopScope(
                                onWillPop: () async {
                                  return true;
                                },
                                child: Padding(
                                    padding:
                                    MediaQuery.of(context)
                                        .viewInsets,
                                    child: _bottomSheetView(incomeDetailBloc)));
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Helper.getCardColor(context)
                      ),
                      child: Icon(
                        Icons.filter_alt_rounded,
                        color: Helper.getTextColor(context),
                        size: 20,
                      ),
                    ),
                  ),
                  10.widthBox,
                ],
              ),
              body: Container(
                color: Helper.getBackgroundColor(context),
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: Text("0%",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),),
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.pinkAccent
                                      ),
                                    ),
                                    5.widthBox,
                                    Text("Collected",
                                      style: TextStyle(
                                          color: Helper.getTextColor(context),
                                          fontSize: 12
                                      ),),
                                  ],
                                ),
                                Text("\u20B90",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    Text("Missing",
                                      style: TextStyle(
                                          color: Helper.getTextColor(context),
                                          fontSize: 12
                                      ),),
                                  ],
                                ),
                                Text("\u20B9798,136.33",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),),
                              ],
                            )
                          ],
                        ),
                      ),

                      20.heightBox,
                      CustomBoxTextFormField(
                          controller: searchController,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(5)),
                          keyboardType: TextInputType.text,
                          hintText: "Notes, categories",
                          fillColor: Helper.getCardColor(context),
                          borderColor: Colors.transparent,
                          padding: 10 ,
                          horizontalPadding: 5,
                          textStyle: TextStyle(color: Helper.getTextColor(context)),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.search,size: 22,color: Colors.grey,),
                          ),
                          validator: (value) {
                            return null;
                          }),

                      20.heightBox,
                      Container(
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Column(
                            children: [
                              20.heightBox,
                              Icon(Icons.account_balance_wallet,color:Helper.getTextColor(context),size: 80,),
                              10.heightBox,
                              Text("You don't have any income yet",
                                style: TextStyle(
                                    color: Helper.getTextColor(context)
                                ),),
                              20.heightBox,
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 35),
                                child: InkWell(
                                  onTap: (){
                                    /*Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddSpendingScreen()),
                                    );*/
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
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  _bottomSheetView(IncomeDetailBloc incomeDetailBloc) {
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
                    Text("Clear filter",
                      style: TextStyle(
                          color: Helper.getTextColor(context),
                          fontSize: 16
                      ),),
                    Expanded(
                      child: Text("Filter",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text("Done",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),),
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.3,
                color: Colors.grey,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                child: Text("YEAR",
                  style: TextStyle(
                      color: Helper.getTextColor(context),
                      fontSize: 14
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 50),
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child: Text("2023",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                child: Text("MONTH(Can filter by one or more)",
                  style: TextStyle(
                      color: Helper.getTextColor(context),
                      fontSize: 14
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("January",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("February",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("March",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
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
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("April",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("May",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("June",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
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
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("July",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("August",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("September",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
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
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("October",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("November",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Text("December",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                child: Text("CATEGORY",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio:2.2 / 1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gridItemList.length,
                  itemBuilder: (BuildContext context, int index) {
                    GridItem item = gridItemList[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      decoration:  BoxDecoration(
                          color: Helper.getCardColor(context),
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Text(item.text,
                        style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 14
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
}
class GridItem {
  final String text;

  GridItem({required this.text});
}
