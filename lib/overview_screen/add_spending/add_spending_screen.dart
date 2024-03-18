import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../db_models/category_model.dart';
import '../../db_models/income_category.dart';
import '../../db_models/income_sub_category.dart';
import '../../db_models/spending_sub_category.dart';
import '../../db_service/database_helper.dart';
import '../../utils/views/custom_text_form_field.dart';
import '../overview_screen.dart';
import 'bloc/add_spending_bloc.dart';
import 'bloc/add_spending_state.dart';

class AddSpendingScreen extends StatefulWidget {
  const AddSpendingScreen({super.key});

  @override
  State<AddSpendingScreen> createState() => _AddSpendingScreenState();
}

class _AddSpendingScreenState extends State<AddSpendingScreen> {

  AddSpendingBloc addSpendingBloc = AddSpendingBloc();

  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  int currPage = 1;

  String selectedValue = 'Spending';
  List<String> dropdownItems = ['Spending', 'Income'];

  final List<String> amount = [
    "2,096",
    "1,555",
    "1,052",
    "950",
    "940",
  ];

  late DateTime currentDate;

  List<Category> selectedItemList = [];
  List<IncomeCategory> selectedIncomeItemList = [];

  List<Category> categories = [];
  List<SpendingSubCategory> spendingSubCategories = [];

  List<IncomeCategory> incomeCategories = [];
  List<IncomeSubCategory> incomeSubCategories = [];

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  Future<void> getSpendingCategory() async {
    try {
      List<Category> fetchedCategories = await databaseHelper.categorys();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (error) {
      setState(() {
      });
    }
  }

  Future<void> getSpendingSubCategory() async {
    try {
      List<SpendingSubCategory> fetchedSpendingSubCategories = await databaseHelper.getSpendingSubCategory(selectedItemList[0].id!.toInt());
      setState(() {
        spendingSubCategories = fetchedSpendingSubCategories;
      });
    } catch (error) {
      setState(() {
      });
    }
  }

  Future<void> getIncomeCategory() async {
    try {
      List<IncomeCategory> fetchedIncomeCategories = await databaseHelper.getIncomeCategory();
      setState(() {
        incomeCategories = fetchedIncomeCategories;
      });
    } catch (error) {
      setState(() {
      });
    }
  }

  Future<void> getIncomeSubCategory() async {
    try {
      List<IncomeSubCategory> fetchedIncomeSubCategories = await databaseHelper.getIncomeSubCategory(selectedIncomeItemList[0].id!.toInt());
      setState(() {
        incomeSubCategories = fetchedIncomeSubCategories;
      });
    } catch (error) {
      setState(() {
      });
    }
  }


  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();

      getSpendingCategory();
  }

  void _incrementDate() {
    setState(() {
      currentDate = currentDate.add(Duration(days: 1));
    });
  }

  void _decrementDate() {
    setState(() {
      currentDate = currentDate.subtract(Duration(days: 1));
    });
  }

  String formattedDate() {
    return DateFormat('dd/MM/yyyy').format(currentDate);
  }

  String formattedTime() {
    return DateFormat('HH:mm').format(currentDate);
  }

  int selectedSpendingSubIndex = -1;
  int selectedIncomeSubIndex = -1;

  @override
  Widget build(BuildContext context) {
    addSpendingBloc.context = context;
    return BlocConsumer<AddSpendingBloc, AddSpendingState>(
      bloc: addSpendingBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is AddSpendingInitial){
          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff29292d),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OverviewScreen()));
                      },
                      child: const Text("Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xff22435b),
                                borderRadius: BorderRadius.circular(25)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                dropdownElevation: 0,
                                buttonDecoration: const BoxDecoration(
                                    color: Colors.transparent),
                                dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xff22435b)),
                                items: dropdownItems
                                    .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(item,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white)),
                                  ),
                                ))
                                    .toList(),
                                dropdownMaxHeight: 200,
                                offset: const Offset(0, -1),
                                value: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    var val = value as String;
                                    selectedValue = val;
                                    if(selectedValue == 'Spending'){
                                      getSpendingCategory();
                                    }else{
                                      getIncomeCategory();
                                    }
                                  });
                                },
                                buttonPadding: EdgeInsets.zero,
                                buttonHeight: 40,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                              ),
                            )),
                      ),
                    ),
                    10.widthBox,
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OverviewScreen()));
                      },
                      child: const Text("Done",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16
                        ),),
                    ),
                  ],
                ),
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration:  const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff152029)
                          ),
                          child: const Icon(Icons.currency_exchange,color: Colors.blue,size: 16,),
                        ),
                        15.widthBox,
                        Expanded(
                            child: CustomBoxTextFormField(
                                controller:amountController,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5)),
                                keyboardType: TextInputType.number,
                                hintText: "0",
                                hintFontSize: 20,
                                hintColor: Colors.blue,
                                fillColor: Colors.white10,
                                textAlign: TextAlign.end,
                                borderColor: Colors.transparent,
                                textStyle: const TextStyle(color: Colors.blue,fontSize: 20),
                                padding: 11 ,
                                horizontalPadding: 5,
                                validator: (value) {
                                  return null;
                                })),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.2,horizontal: 5),
                          decoration: const BoxDecoration(
                              color: Colors.white10,
                              border: Border(
                                left: BorderSide(
                                  color: Colors.white10,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5))),
                          child:  Row(
                            children: [
                              5.widthBox,
                              const Text("\u20B9",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:16,
                                      color: Colors.blue)),
                              5.widthBox,
                              const Icon(Icons.arrow_forward_ios_outlined,size: 12,color: Colors.white,)
                            ],
                          ),
                        ),
                      ]),

                      10.heightBox,
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: amount.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Color(0xff29292d),
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Text(amount[index],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14
                                ),),
                            );
                          },
                          separatorBuilder:
                              (BuildContext context,
                              int index) {
                            return 10.widthBox;
                          },
                        ),
                      ),

                      20.heightBox,
                      selectedValue == "Spending"
                     ? Row(
                        children: [
                          const Text("CATEGORY",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14
                            ),),
                          10.widthBox,
                          const Icon(Icons.settings,color: Colors.blue,size: 18,),
                          if(selectedItemList.isNotEmpty)
                          Expanded(
                            child: Text(selectedItemList[0].name.toString(),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                              ),),
                          ),
                          5.widthBox,
                          if(selectedItemList.isNotEmpty)
                          InkWell(
                            onTap: (){
                              setState(() {
                                selectedSpendingSubIndex = -1;
                                selectedItemList.clear();
                              });
                            },
                              child: const Icon(Icons.highlight_remove,color: Colors.white,size: 18,)),
                        ],
                      )
                      :Row(
                        children: [
                          const Text("CATEGORY",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14
                            ),),
                          10.widthBox,
                          const Icon(Icons.settings,color: Colors.blue,size: 18,),
                          if(selectedIncomeItemList.isNotEmpty)
                            Expanded(
                              child: Text(selectedIncomeItemList[0].name.toString(),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14
                                ),),
                            ),
                          5.widthBox,
                          if(selectedIncomeItemList.isNotEmpty)
                            InkWell(
                                onTap: (){
                                  setState(() {
                                    selectedIncomeSubIndex = -1;
                                    selectedIncomeItemList.clear();
                                  });
                                },
                                child: const Icon(Icons.highlight_remove,color: Colors.white,size: 18,)),
                        ],
                      ),

                      5.heightBox,
                      selectedValue == "Spending"
                          ?Stack(
                        children: [
                         GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                                childAspectRatio:4 / 4,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: selectedItemList.isEmpty ? categories.length : selectedItemList.length,
                              itemBuilder: (BuildContext context, int index) {
                                Category item = selectedItemList.isEmpty ? categories[index] : selectedItemList[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedItemList.add(categories[index]);
                                      getSpendingSubCategory();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.white10,
                                        /*border: Border.all(
                                          color: Colors.blue,
                                          width: 1,
                                        ),*/
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    child: Column(
                                      children: [
                                        SvgPicture.asset('asset/images/${item.icons}.svg',color: Colors.blue,width: 28,
                                          height: 28,),
                                        Expanded(
                                          child: Text(item.name.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (selectedItemList.isNotEmpty)
                            Positioned(
                              top: 0,
                                bottom: 0,
                                left: 0,
                                right: MediaQuery.of(context).size.width / 1.8,
                                child: const VerticalDivider(color: Colors.blue, thickness: 3)),
                          Row(
                            children: [
                              if(selectedItemList.isNotEmpty)
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4.8,
                                ),
                              if(selectedItemList.isNotEmpty)
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4.0,
                                      mainAxisSpacing: 4.0,
                                      childAspectRatio:3.5 / 1,
                                    ),
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: spendingSubCategories.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      SpendingSubCategory item = spendingSubCategories[index];
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedSpendingSubIndex = index;
                                        });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color:  selectedSpendingSubIndex == index ? Colors.blue : Colors.white10,
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Text(item.name!,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          )
                        ],
                      )
                          :Stack(
                        children: [
                          GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                              childAspectRatio:4 / 4,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selectedIncomeItemList.isEmpty ? incomeCategories.length : selectedIncomeItemList.length,
                            itemBuilder: (BuildContext context, int index) {
                              IncomeCategory item = selectedIncomeItemList.isEmpty ? incomeCategories[index] : selectedIncomeItemList[index];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedIncomeItemList.add(incomeCategories[index]);
                                    getIncomeSubCategory();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white10,
                                      /*border: Border.all(
                                        color: Colors.blue,
                                        width: 1,
                                      ),*/
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset('asset/images/${item.path}.svg',color: Colors.blue,width: 28,
                                        height: 28,),
                                      Expanded(
                                        child: Text(item.name.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (selectedIncomeItemList.isNotEmpty)
                            Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: MediaQuery.of(context).size.width / 1.8,
                                child: const VerticalDivider(color: Colors.blue, thickness: 3)),
                          Row(
                            children: [
                              if(selectedIncomeItemList.isNotEmpty)
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4.8,
                                ),
                              if(selectedIncomeItemList.isNotEmpty)
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4.0,
                                      mainAxisSpacing: 4.0,
                                      childAspectRatio:3.5 / 1,
                                    ),
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: incomeSubCategories.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      IncomeSubCategory item = incomeSubCategories[index];
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedIncomeSubIndex = index;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color:  selectedIncomeSubIndex == index ?Colors.blue : Colors.white10,
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Text(item.name!,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                      20.heightBox,
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration:  const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff152029)
                          ),
                          child: const Icon(Icons.calendar_month_sharp,color: Colors.blue,size: 16,),
                        ),
                        15.widthBox,
                        InkWell(
                          onTap: (){
                            _decrementDate();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: const Icon(Icons.calendar_month_sharp,color: Colors.grey,),
                          ),
                        ),
                        5.widthBox,
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 5),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text( formattedDate(),
                                  style: TextStyle(color: Colors.white),),
                                5.widthBox,
                                Text(
                                  formattedTime(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                ],
                            ),
                          ),
                        ),
                        5.widthBox,
                        InkWell(
                          onTap: (){
                            _incrementDate();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: const Icon(Icons.calendar_month_sharp,color: Colors.grey,),
                          ),
                        ),
                      ]),

                      10.heightBox,
                      Stack(
                        children: [
                          Row(
                            children: [
                              InkWell(onTap: () {
                                setState(() {
                                  currPage = 1;
                                });
                              },
                                child:  Column(
                                    children: [
                                      Text("DETAILS",
                                        style: TextStyle(
                                            color: currPage == 1 ? Colors.blue : Colors.white,
                                            fontSize: 14
                                        ),),
                                     currPage == 1 ?
                                      Container(
                                        width: 55,
                                        height: 2,
                                        color: Colors.blue,
                                      ):Container()
                                    ],
                                  ),
                              ),
                            ],
                          ),
                          const Positioned(
                            bottom: -8,
                            left: 0,
                            right: 0,
                            child: Divider(
                              thickness: 2,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      10.heightBox,
                       currPage == 1
                          ? _detailsView(addSpendingBloc)
                          : 0.heightBox,
                    ],
                  ),
                ),
              ));
        }
        return Container();
      },
    );
  }

  Widget _detailsView(AddSpendingBloc addSpendingBloc) {
    return Column(
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration:  const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff152029)
            ),
            child: const Icon(Icons.menu,color: Colors.blue,size: 16,),
          ),
          15.widthBox,
          Expanded(
              child: CustomBoxTextFormField(
                  controller: descriptionController,
                  borderRadius: const BorderRadius.all(
                       Radius.circular(5)),
                  keyboardType: TextInputType.number,
                  hintText: "Enter description",
                  fillColor: Colors.white10,
                  borderColor: Colors.transparent,
                  padding: 11 ,
                  horizontalPadding: 5,
                  validator: (value) {
                    return null;
                  })),
        ]),

        10.heightBox,
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration:  const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff152029)
            ),
            child: const Icon(Icons.menu,color: Colors.blue,size: 16,),
          ),
          15.widthBox,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Column(
              children: [
                const Icon(Icons.wallet,color: Colors.white,),
                5.heightBox,
                const Text("Cash",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                  ),
                ),
              ],
            ),
          )
        ]),

        10.heightBox,
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration:  const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff152029)
            ),
            child: const Icon(Icons.menu,color: Colors.blue,size: 16,),
          ),
          15.widthBox,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: const Icon(Icons.camera_alt_outlined,color: Colors.blue,),
          ),
          10.widthBox,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: const Icon(Icons.camera_alt_outlined,color: Colors.blue,),
          ),
          10.widthBox,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: const Icon(Icons.camera_alt_outlined,color: Colors.blue,),
          )
        ]),
      ],
    );
  }


}


