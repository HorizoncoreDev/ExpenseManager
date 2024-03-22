import 'dart:io';
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/my_library_bloc.dart';
import 'bloc/my_library_state.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  MyLibraryBloc myLibraryBloc = MyLibraryBloc();
  final List<String> imageList = [
  ];
  List<TransactionModel> spendingTransaction = [];
  List<TransactionModel> incomeTransaction = [];
  String userEmail = "";
  int currentBalance = 0;
  int actualBudget = 0;
  bool isSkippedUser = false;
  final databaseHelper = DatabaseHelper();

  @override
  void initState() {
    getTransaction();
    super.initState();
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
            if(getImage1.isNotEmpty){
              imageList.add(getImage1);
            }
            if(getImage2.isNotEmpty){
              imageList.add(getImage2);
            }
            if(getImage3.isNotEmpty){
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
          if(getImage1.isNotEmpty){
            imageList.add(getImage1);
          }
          if(getImage2.isNotEmpty){
            imageList.add(getImage2);
          }
          if(getImage3.isNotEmpty){
            imageList.add(getImage3);
          }
        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    myLibraryBloc.context = context;
    return BlocConsumer<MyLibraryBloc, MyLibraryState>(
      bloc: myLibraryBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is MyLibraryInitial) {
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
                    Text("My Library",
                        style: TextStyle(
                          fontSize: 22,
                          color: Helper.getTextColor(context),
                        )),
                  ],
                ),
              ),

              body: imageList.isEmpty ?
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 250,
                    decoration: BoxDecoration(
                        color: Helper.getCardColor(context),
                        borderRadius:
                        BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      children: [
                        20.heightBox,
                        Icon(
                          Icons.account_balance_wallet,
                          color: Helper.getTextColor(context),
                          size: 80,
                        ),
                        10.heightBox,
                        Text(
                          "You don't have any library yet",
                          style: TextStyle(
                              color: Helper.getTextColor(context)),
                        ),
                        20.heightBox,
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 35),
                          child: InkWell(
                            onTap: () {
                              /*Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AddSpendingScreen()),
                                      );*/
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10))),
                              child: const Text(
                                "Add library",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        15.heightBox,
                      ],
                    )),
              ) :
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns in the grid
                    crossAxisSpacing: 8.0, // Spacing between columns
                    mainAxisSpacing: 8.0, // Spacing between rows
                    childAspectRatio: 1.2
                  ),
                  itemCount: imageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Image.file(
                      File(imageList[index]),
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
