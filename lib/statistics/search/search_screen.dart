import 'package:expense_manager/statistics/search/CommonCategoryModel.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../db_models/transaction_model.dart';
import '../../db_service/database_helper.dart';
import '../../overview_screen/add_spending/DateWiseTransactionModel.dart';
import '../../utils/global.dart';
import '../../utils/my_shared_preferences.dart';
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
  String userEmail = "";
  TextEditingController searchController = TextEditingController();
  List<DateWiseTransactionModel> dateWiseTransaction = [];
  List<DateWiseTransactionModel> originalDateWiseTransaction = [];
  List<CommonCategoryModel> categoryList = [];

  @override
  void initState() {
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
      }
      getTransactions("");
    });
    getCategories();
    super.initState();
  }

  getCategories() async {
  await DatabaseHelper.instance.categorys().then((value) {
    if(value.isNotEmpty){
      for(var s in value){
       categoryList.add(CommonCategoryModel(catId: s.id,catName: s.name));
      }
    }
  });
  await DatabaseHelper.instance.getIncomeCategory().then((value) {
    if(value.isNotEmpty){
      for(var s in value){
        categoryList.add(CommonCategoryModel(catId: s.id,catName: s.name));
      }
    }
  });
  }

  @override
  Widget build(BuildContext context) {
    searchBloc.context = context;
    return BlocConsumer<SearchBloc, SearchState>(
      bloc: searchBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SearchInitial) {
          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Helper.getBackgroundColor(context),
                title: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Helper.getTextColor(context),
                          size: 20,
                        )),
                    Text("Search",
                        style: TextStyle(
                          fontSize: 22,
                          color: Helper.getTextColor(context),
                        )),
                  ],
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
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
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: _bottomSheetView(searchBloc)));
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Helper.getCardColor(context)),
                      child: Icon(
                        Icons.filter_alt_rounded,
                        color: Helper.getTextColor(context),
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
                          color: Helper.getCardColor(context)),
                      child: const Icon(
                        Icons.family_restroom_sharp,
                        color: Colors.blue,
                      ),
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        keyboardType: TextInputType.text,
                        hintText: "Search by category, note",
                        fillColor: Helper.getCardColor(context),
                        borderColor: Colors.transparent,
                        padding: 10,
                        textStyle:
                            TextStyle(color: Helper.getTextColor(context)),
                        horizontalPadding: 5,
                        suffixIcon: searchController.text.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  searchController.clear();
                                  getTransactions("");
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.close,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.search,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                              ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            getTransactions(value);
                          } else {
                            dateWiseTransaction = originalDateWiseTransaction;
                            getTransactions("");
                          }
                        },
                        validator: (value) {
                          return null;
                        }),
                    if (dateWiseTransaction.isNotEmpty) 15.heightBox,
                    if (dateWiseTransaction.isNotEmpty) _transactionView(),
                    if (dateWiseTransaction.isEmpty)
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "No data matching.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }

  getTransactions(String category) async {
    List<TransactionModel> spendingTransaction = [];
    dateWiseTransaction = [];
    await DatabaseHelper.instance
        .getTransactionList(category.toLowerCase(),userEmail)
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
      dates.sort((a, b) => b.compareTo(a));
      for (var date in dates) {
        int totalAmount = 0;
        List<TransactionModel> newTransaction = [];
        var incomeTransactionTotal = 0;
        var spendingTransactionTotal = 0;
        for (var t in spendingTransaction) {
          if (date == t.transaction_date!.split(' ')[0]) {
            newTransaction.add(t);
            if (t.transaction_type == AppConstanst.incomeTransaction) {
              incomeTransactionTotal = incomeTransactionTotal + t.amount!;
            } else {
              spendingTransactionTotal = spendingTransactionTotal + t.amount!;
            }
          } else {
            DateWiseTransactionModel? found =
                dateWiseTransaction.firstWhereOrNull((element) =>
                    element.transactionDate!.split(' ')[0] == date);
            if (found == null) {
              continue;
            } else {
              break;
            }
          }
        }
        totalAmount = incomeTransactionTotal - spendingTransactionTotal;
        dateWiseTransaction.add(DateWiseTransactionModel(
            transactionDate: date,
            transactionTotal: totalAmount,
            transactionDay: Helper.getTransactionDay(date),
            transactions: newTransaction));
        originalDateWiseTransaction.add(DateWiseTransactionModel(
            transactionDate: date,
            transactionTotal: totalAmount,
            transactionDay: Helper.getTransactionDay(date),
            transactions: newTransaction));
      }
      setState(() {});
    });
  }

  filterList(String category) async {
    List<DateWiseTransactionModel> tempDateWiseTransaction = [];
    for (var d in dateWiseTransaction) {
      for (var t in d.transactions!) {
        if (t.cat_name!.toLowerCase().contains(category.toLowerCase())) {
          tempDateWiseTransaction.add(d);
        }
      }
    }
    setState(() {
      dateWiseTransaction = tempDateWiseTransaction;
    });
  }

  Widget _transactionView() {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: dateWiseTransaction.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${dateWiseTransaction[index].transactionDay}, ${dateWiseTransaction[index].transactionDate}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    dateWiseTransaction[index].transactionTotal! < 0
                        ? "-\u20B9${dateWiseTransaction[index].transactionTotal.toString().replaceAll("-", '')}"
                        : '+\u20B9${dateWiseTransaction[index].transactionTotal}',
                    style: const TextStyle(color: Colors.pink, fontSize: 14),
                  ),
                ],
              ),
              15.heightBox,
              if (dateWiseTransaction[index].transactions!.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: dateWiseTransaction[index].transactions!.length,
                  itemBuilder: (context, index1) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: Color(0xff30302d),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: SvgPicture.asset(
                              'asset/images/${dateWiseTransaction[index].transactions![index1].cat_icon}.svg',
                              color: dateWiseTransaction[index]
                                  .transactions![index1]
                                  .cat_color,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          15.widthBox,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateWiseTransaction[index]
                                      .transactions![index1]
                                      .cat_name!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (dateWiseTransaction[index]
                                                  .transactions![index1]
                                                  .description ==
                                              null ||
                                          dateWiseTransaction[index]
                                              .transactions![index1]
                                              .description!
                                              .isEmpty)
                                      ? 'No note'
                                      : dateWiseTransaction[index]
                                          .transactions![index1]
                                          .description!,
                                  style: const TextStyle(
                                    color: Colors.white,
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
                                dateWiseTransaction[index]
                                            .transactions![index1]
                                            .transaction_type ==
                                        AppConstanst.spendingTransaction
                                    ? "-\u20B9${dateWiseTransaction[index].transactions![index1].amount!}"
                                    : "+\u20B9${dateWiseTransaction[index].transactions![index1].amount!}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${dateWiseTransaction[index].transactions![index1].payment_method_id == AppConstanst.cashPaymentType ? 'Cash' : ''}/${dateWiseTransaction[index].transactions![index1].transaction_date!.split(' ')[1]}",
                                style: const TextStyle(
                                  color: Colors.white,
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
    );
  }

  _bottomSheetView(SearchBloc searchBloc) {
    return Container(
        padding: const EdgeInsets.only(bottom: 10),
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
                    Text(
                      "Clear filter",
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        "Filter",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  "YEAR",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: const Text(
                    "2023",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  "MONTH(Can filter by one or more)",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "January",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "February",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "March",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "April",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "May",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "June",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "July",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "August",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "September",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "October",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "November",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    10.widthBox,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Helper.getCardColor(context),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          "December",
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  "CATEGORY",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 2 / 1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Helper.getCardColor(context),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: Text(
                        categoryList[index].catName!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 14),
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
