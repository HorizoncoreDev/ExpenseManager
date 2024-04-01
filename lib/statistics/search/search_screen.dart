import 'package:expense_manager/statistics/search/CommonCategoryModel.dart';
import 'package:expense_manager/statistics/statistics_screen.dart';
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
  List<TransactionModel> spendingTransaction = [];
  List<TransactionModel> incomeTransaction = [];
  String showYear = 'Select Year';
  String showMonth = 'Select month';
  DateTime _selectedYear = DateTime.now();
  int isIncome = 0;

  List<MonthData> monthList = [
    MonthData(text: 'January'),
    MonthData(text: 'February'),
    MonthData(text: 'March'),
    MonthData(text: 'April'),
    MonthData(text: 'May'),
    MonthData(text: 'June'),
    MonthData(text: 'July'),
    MonthData(text: 'August'),
    MonthData(text: 'September'),
    MonthData(text: 'October'),
    MonthData(text: 'November'),
    MonthData(text: 'December'),
  ];
  List<MonthData> selectedMonths = [];
  String selectedCategory = "";
  int selectedCategoryIndex = -1;

  bool isFilterCleared = false;

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
      if (value.isNotEmpty) {
        for (var s in value) {
          categoryList.add(CommonCategoryModel(
              catId: s.id,
              catName: s.name,
              catType: AppConstanst.spendingTransaction));
        }
      }
    });
    await DatabaseHelper.instance.getIncomeCategory().then((value) {
      if (value.isNotEmpty) {
        for (var s in value) {
          categoryList.add(CommonCategoryModel(
              catId: s.id,
              catName: s.name,
              catType: AppConstanst.incomeTransaction));
        }
      }
    });
  }

  getFilteredData(String value) async {
    int expenseCatId = -1;
    int incomeCatId = -1;
    if(selectedCategoryIndex!=-1) {
      if (categoryList[selectedCategoryIndex].catType ==
          AppConstanst.incomeTransaction) {
        incomeCatId = categoryList[selectedCategoryIndex].catId!;
      } else {
        expenseCatId = categoryList[selectedCategoryIndex].catId!;
      }
    }
    List<TransactionModel> spendingTransaction = [];
    dateWiseTransaction = [];

    await DatabaseHelper.instance
        .fetchAllDataForYearMonthsAndCategory(
        showYear, selectedMonths, expenseCatId, incomeCatId, userEmail,value)
        .then((value) {
      spendingTransaction = value;
      List<String> dates = [];
      for (var t in spendingTransaction) {
        if (!dates.contains(t.transaction_date!.split(' ')[0])) {
          dates.add(t.transaction_date!.split(' ')[0]);
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
      }
      print('object....${dates}');
      setState(() {});
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
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return WillPopScope(
                                    onWillPop: () async {
                                      return true;
                                    },
                                    child: Padding(
                                        padding:
                                        MediaQuery.of(context).viewInsets,
                                        child: _bottomSheetView(
                                            setState)));
                              },
                            );
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
                  /*  Padding(
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
                  )*/
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
                            if (showYear != "Select Year" &&
                                selectedMonths.isNotEmpty) {
                              getFilteredData("");
                            }else {
                              getTransactions("");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.close,
                              size: 22,
                              color: Helper.getTextColor(context),
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
                            if (showYear != "Select Year" &&
                                selectedMonths.isNotEmpty) {
                              getFilteredData(value);
                            } else {
                              getTransactions(value);
                            }
                          } else {
                            dateWiseTransaction = originalDateWiseTransaction;
                            if (showYear != "Select Year" &&
                                selectedMonths.isNotEmpty) {
                              getFilteredData("");
                            }else {
                              getTransactions("");
                            }
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
        .getTransactionList(category.toLowerCase(), userEmail,-1)
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
                      decoration: BoxDecoration(
                          color: Helper.getCardColor(context),
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
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
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
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
                                  style: TextStyle(
                                    color: Helper.getTextColor(context),
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
                                style: TextStyle(
                                    color: Helper.getTextColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${dateWiseTransaction[index].transactions![index1].payment_method_id == AppConstanst.cashPaymentType ? 'Cash' : ''}/${dateWiseTransaction[index].transactions![index1].transaction_date!.split(' ')[1]}",
                                style: TextStyle(
                                  color: Helper.getTextColor(context),
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

  _bottomSheetView( StateSetter setState) {
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
                    InkWell(
                      onTap: () {
                        clearSelection(setState);
                      },
                      child: Text(
                        "Clear filter",
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 16),
                      ),
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
                        if(isFilterCleared){
                          Navigator.pop(context);
                          getTransactions("");
                        }else {
                          isFilterCleared = false;
                          if (showYear != "Select Year" &&
                              selectedMonths.isNotEmpty) {
                            Navigator.pop(context);
                            getFilteredData("");
                          } else if (showYear == "Select Year" ||
                              selectedMonths.isEmpty) {
                            Helper.showToast(
                                "Please ensure you select a year and month to retrieve data");
                          } else {
                            Navigator.pop(context);
                            getTransactions("");
                          }
                        }
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "YEAR",
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 14),
                    ),
                    15.widthBox,
                    Text(
                      "MONTH(Can filter one or more)",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          selectYear(context, setState);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 50),
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                          child: Text(
                            showYear,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      15.widthBox,
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectMonth(context, setState);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                BorderRadius.all(Radius.circular(5))),
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              showMonth,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  "CATEGORY",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 2,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (selectedCategoryIndex != -1) {
                            categoryList[selectedCategoryIndex].isSelected =
                            false;
                          }
                          categoryList[index].isSelected = true;
                          selectedCategoryIndex = index;
                          selectedCategory = categoryList[index].catName!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: categoryList[index].isSelected
                                ? Colors.blue
                                : Helper.getCardColor(context),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          categoryList[index].catName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
              15.heightBox
            ],
          ),
        ));
  }

  void clearSelection(StateSetter setState) {
    setState(() {
      isFilterCleared = true;
      for (var month in monthList) {
        month.isSelected = false;
      }
      for (var item in categoryList) {
        item.isSelected = false;
      }
      selectedMonths.clear();
      showMonth = 'Select Month';
      showYear = 'Select Year';
      selectedCategoryIndex = -1;
      selectedCategory = '';
    });
  }

  selectYear(context, StateSetter setState) async {
    print("Calling date picker");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 10, 1),
              lastDate: DateTime.now(),
              //lastDate: DateTime(2025),
              initialDate: DateTime.now(),
              selectedDate: _selectedYear,
              onChanged: (DateTime dateTime) {
                setState(() {
                  _selectedYear = dateTime;
                  showYear = "${dateTime.year}";
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  selectMonth(context, StateSetter setState) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState1) {
          return AlertDialog(
            title: const Text("Select Month"),
            contentPadding:
            const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2.2 / 1,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: monthList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState1(() {
                            monthList[index].isSelected =
                            !monthList[index].isSelected;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: monthList[index].isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                          child: Text(
                            monthList[index].text,
                            style: TextStyle(
                                color: Helper.getTextColor(context),
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              InkWell(
                onTap: () {
                  setState(() {
                    List<String> showMonthList = [];
                    selectedMonths =
                        monthList.where((month) => month.isSelected).toList();
                    for (var i in selectedMonths) {
                      showMonthList.add(i.text);
                    }
                    showMonth = showMonthList.join(", ");
                    Navigator.pop(context);
                  });
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
          );
        });
      },
    );
  }

}