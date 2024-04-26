import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../db_models/income_sub_category.dart';
import '../../../db_models/expense_sub_category.dart';
import '../../../db_service/database_helper.dart';
import '../../../utils/helper.dart';
import '../../../utils/views/custom_text_form_field.dart';
import 'bloc/sub_category_bloc.dart';
import 'bloc/sub_category_state.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  final int currPage;

  const SubCategoryScreen(
      {super.key,
      required this.categoryName,
      required this.categoryId,
      required this.currPage});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  SubCategoryBloc subCategoryBloc = SubCategoryBloc();

  TextEditingController nameController = TextEditingController();

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  List<ExpenseSubCategory> spendingSubCategories = [];
  bool isLoading = true;

  Future<void> getSpendingSubCategory() async {
    isLoading = true;
    try {
      List<ExpenseSubCategory> fetchedSpendingSubCategories =
          await databaseHelper.getSpendingSubCategory(widget.categoryId);
      setState(() {
        spendingSubCategories = fetchedSpendingSubCategories;
        isLoading = false; // Set loading state to false when data is fetched
      });
    } catch (error) {
      //print('Error fetching sub categories: $error');
      setState(() {
        isLoading = false; // Set loading state to false on error
      });
    }
  }

  Future<void> _addSpendingSubCategory() async {
    final name = nameController.text;

    await databaseHelper.insertSpendingSubCategory(
      widget.categoryId,
      ExpenseSubCategory(
          name: name, categoryId: widget.categoryId, priority: ""),
    );
    getSpendingSubCategory();
    //Navigator.pop(context);
  }

  List<IncomeSubCategory> incomeSubCategories = [];

  Future<void> getIncomeSubCategory() async {
    isLoading = true;
    try {
      List<IncomeSubCategory> fetchedIncomeSubCategories =
          await databaseHelper.getIncomeSubCategory(widget.categoryId);
      setState(() {
        incomeSubCategories = fetchedIncomeSubCategories;
        isLoading = false; // Set loading state to false when data is fetched
      });
    } catch (error) {
      //print('Error fetching sub categories: $error');
      setState(() {
        isLoading = false; // Set loading state to false on error
      });
    }
  }

  Future<void> _addIncomeSubCategory() async {
    final name = nameController.text;

    await databaseHelper.insertIncomeSubCategory(
      widget.categoryId,
      IncomeSubCategory(
          name: name, categoryId: widget.categoryId, priority: ""),
    );
    getIncomeSubCategory();
    //Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.currPage == 1) {
      getSpendingSubCategory();
    } else {
      getIncomeSubCategory();
    }
  }

  @override
  Widget build(BuildContext context) {
    subCategoryBloc.context = context;
    return BlocConsumer<SubCategoryBloc, SubCategoryState>(
      bloc: subCategoryBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SubCategoryInitial) {
          return SafeArea(
            child: Scaffold(
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
                    RichText(
                        text: TextSpan(
                            text: widget.categoryName,
                            style: TextStyle(
                              fontSize: 22,
                              color: Helper.getTextColor(context),
                            ),
                            children: [
                          TextSpan(
                            text: widget.currPage == 1
                                ? '(${spendingSubCategories.length})'
                                : '(${incomeSubCategories.length})',
                            style: TextStyle(
                              fontSize: 18,
                              color: Helper.getTextColor(context),
                            ),
                          ),
                        ])),
                  ],
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      _addSubCategoryDialogue(subCategoryBloc).then((value) {
                        if (value != null && value) {
                          if (widget.currPage == 1) {
                            getSpendingSubCategory();
                          } else {
                            getIncomeSubCategory();
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Helper.getCardColor(context)),
                      child: Icon(
                        Icons.add,
                        color: Helper.getTextColor(context),
                        size: 22,
                      ),
                    ),
                  ),
                  10.widthBox,
                ],
              ),
              body: widget.currPage == 1
                  ? Container(
                      color: Helper.getBackgroundColor(context),
                      height: double.infinity,
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : spendingSubCategories.isEmpty
                              ? Center(
                                  child: Text(
                                  'No sub categories found.',
                                  style: TextStyle(
                                    color: Helper.getTextColor(context),
                                  ),
                                ))
                              : SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Helper.getCardColor(context),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: spendingSubCategories.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 5,
                                                bottom: 5),
                                            child: Row(
                                              children: [
                                                10.widthBox,
                                                Expanded(
                                                  child: Text(
                                                    spendingSubCategories[index]
                                                        .name!,
                                                    style: TextStyle(
                                                        color:
                                                            Helper.getTextColor(
                                                                context),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const Divider(
                                            thickness: 0.3,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                    )
                  : Container(
                      color: Helper.getBackgroundColor(context),
                      height: double.infinity,
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : incomeSubCategories.isEmpty
                              ? Center(
                                  child: Text(
                                  'No sub categories found.',
                                  style: TextStyle(
                                      color: Helper.getTextColor(context)),
                                ))
                              : SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Helper.getCardColor(context),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: incomeSubCategories.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 5,
                                                bottom: 5),
                                            child: Row(
                                              children: [
                                                10.widthBox,
                                                Expanded(
                                                  child: Text(
                                                    incomeSubCategories[index]
                                                        .name!,
                                                    style: TextStyle(
                                                        color:
                                                            Helper.getTextColor(
                                                                context),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const Divider(
                                            thickness: 0.3,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
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

  Future _addSubCategoryDialogue(SubCategoryBloc subCategoryBloc) async {
    await showDialog(
      context: subCategoryBloc.context,
      builder: (cont) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          insetPadding: const EdgeInsets.all(0),
          backgroundColor: Helper.getCardColor(context),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                10.heightBox,
                Text(
                  "Name",
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 14),
                ),
                5.heightBox,
                CustomBoxTextFormField(
                    controller: nameController,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    keyboardType: TextInputType.text,
                    fillColor: Helper.getCardColor(context),
                    borderColor: Colors.transparent,
                    textStyle: TextStyle(color: Helper.getTextColor(context)),
                    padding: 10,
                    horizontalPadding: 5,
                    validator: (value) {
                      return null;
                    }),
                15.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Priority",
                      style: TextStyle(
                          color: Helper.getTextColor(context), fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                      child: const Icon(
                        Icons.question_mark,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ],
                ),
                10.heightBox,
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      ),
                    ),
                    4.widthBox,
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      ),
                    ),
                    4.widthBox,
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      ),
                    ),
                  ],
                ),
                10.heightBox,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Low",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Medium",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "High",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Helper.getTextColor(context), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                30.heightBox,
                InkWell(
                  onTap: () async {
                    if (widget.currPage == 1) {
                      await _addSpendingSubCategory();
                      getSpendingSubCategory();
                    } else {
                      await _addIncomeSubCategory();
                      getIncomeSubCategory();
                    }
                    nameController.clear();
                    Navigator.pop(cont);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                10.heightBox,
              ],
            ),
          ),
        );
      },
    );
  }
}
