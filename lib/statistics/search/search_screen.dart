import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/views/custom_text_form_field.dart';
import 'bloc/search_bloc.dart';
import 'bloc/search_state.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  SearchBloc searchBloc = SearchBloc();
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
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    searchBloc.context = context;
    return BlocConsumer<SearchBloc, SearchState>(
      bloc: searchBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is SearchInitial){
          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Helper.getBackgroundColor(context),
                title: Row(
                  children: [
                    InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child:  Icon(Icons.arrow_back_ios,color: Helper.getTextColor(context),size: 20,)),
                     Text("Search",
                        style: TextStyle(
                          fontSize: 22,
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
                                  /*orderListingController
                                      .isFilterClicked
                                      .value = false;*/
                                  return true;
                                },
                                child: Padding(
                                    padding:
                                    MediaQuery.of(context)
                                        .viewInsets,
                                    child: _bottomSheetView(
                                        searchBloc)));
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Helper.getCardColor(context)
                      ),
                      child: const Icon(
                        Icons.filter_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  10.widthBox,
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Helper.getCardColor(context)
                      ),
                      child:const Icon(Icons.family_restroom_sharp,color: Colors.blue,),
                    ),
                  )
                ],
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: Helper.getBackgroundColor(context),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.heightBox,
                    CustomBoxTextFormField(
                        controller: searchController,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(10)),
                        keyboardType: TextInputType.text,
                        hintText: "Search by category, note",
                        fillColor: Helper.getCardColor(context),
                        borderColor: Colors.transparent,
                        padding: 10 ,
                        horizontalPadding: 5,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.search,size: 22,color: Colors.grey,),
                        ),
                        validator: (value) {
                          return null;
                        }),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("No data matching.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 18
                          ),),
                      ),
                    ),
                    /*20.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("WEDNESDAY, 27/12/2023",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14
                          ),),
                        Text("+\u20B98",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14
                          ),),
                      ],
                    ),
                    10.heightBox,
                    Container(
                      decoration: const BoxDecoration(
                          color: Color(0xff30302d),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
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
                          );
                        },
                        separatorBuilder:
                            (BuildContext context,
                            int index) {
                          return Divider(
                            thickness: 0.3,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),*/
                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }


  _bottomSheetView(SearchBloc searchBloc) {
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
                              Navigator.of(context).pop(false);
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
                      color: Helper.getTextColor(context),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                      child: Text("YEAR",
                        style: TextStyle(
                            color: Colors.grey,
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
                            color: Colors.grey,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Text("December",
                                style: TextStyle(
                                    color: Colors.white,
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
                                  color: Colors.white,
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
