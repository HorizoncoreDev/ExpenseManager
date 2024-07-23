import 'dart:io';

import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  final List<String> imageList = [];
  List<TransactionModel> spendingTransaction = [];
  List<TransactionModel> incomeTransaction = [];
  String userEmail = "";
  int currentBalance = 0;
  int actualBudget = 0;
  bool isSkippedUser = false;
  final databaseHelper = DatabaseHelper();


  @override
  Widget build(BuildContext context) {
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
              10.widthBox,
              Text(LocaleKeys.myLibrary.tr,
                  style: TextStyle(
                    fontSize: 22,
                    color: Helper.getTextColor(context),
                  )),
            ],
          ),
        ),
        body: imageList.isEmpty
            ? Center(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    LocaleKeys.haveNotLibrary.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Helper.getTextColor(context), fontSize: 18),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns in the grid
                      crossAxisSpacing: 8.0, // Spacing between columns
                      mainAxisSpacing: 8.0, // Spacing between rows
                      childAspectRatio: 1.2),
                  itemCount: imageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        _showImage(context, File(imageList[index]),);
                      },
                      child: Image.file(
                        File(imageList[index]),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  getTransaction() async {
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
        if (isSkippedUser) {
        } else {
          MySharedPreferences.instance
              .getStringValuesSF(SharedPreferencesKeys.userEmail)
              .then((value) {
            if (value != null) {
              userEmail = value;
            }
          });
        }
      }
    });
    await DatabaseHelper.instance
        .getTransactions(AppConstanst.spendingTransaction)
        .then((value) {
      setState(() {
        spendingTransaction = value;
        for (int i = 0; i < spendingTransaction.length; i++) {
          String getImage1 = spendingTransaction[i].receipt_image1.toString();
          String getImage2 = spendingTransaction[i].receipt_image2.toString();
          String getImage3 = spendingTransaction[i].receipt_image3.toString();
          if (getImage1.isNotEmpty) {
            imageList.add(getImage1);
          }
          if (getImage2.isNotEmpty) {
            imageList.add(getImage2);
          }
          if (getImage3.isNotEmpty) {
            imageList.add(getImage3);
          }
        }
      });
    });

    await DatabaseHelper.instance
        .getTransactions(AppConstanst.incomeTransaction)
        .then((value) {
      setState(() {
        incomeTransaction = value;
        for (int i = 0; i < incomeTransaction.length; i++) {
          String getImage1 = incomeTransaction[i].receipt_image1.toString();
          String getImage2 = incomeTransaction[i].receipt_image2.toString();
          String getImage3 = incomeTransaction[i].receipt_image3.toString();
          if (getImage1.isNotEmpty) {
            imageList.add(getImage1);
          }
          if (getImage2.isNotEmpty) {
            imageList.add(getImage2);
          }
          if (getImage3.isNotEmpty) {
            imageList.add(getImage3);
          }
        }
      });
    });
  }

  @override
  void initState() {
    getTransaction();
    super.initState();
  }

  void _showImage(BuildContext context, File image) async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            buttonPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  style: const ButtonStyle(
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // the '2023' part
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  constraints: const BoxConstraints(),
                ),
                5.heightBox,
                Center(
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        image,
                        frameBuilder: (BuildContext context, Widget child,
                            int? frame, bool wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  )),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                10.heightBox,
              ],
            )));
  }
}
