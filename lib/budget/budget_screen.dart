import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../dashboard/dashboard.dart';
import '../utils/global.dart';
import '../utils/views/custom_text_form_field.dart';
import 'bloc/budget_bloc.dart';
import 'bloc/budget_event.dart';
import 'bloc/budget_state.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetBloc budgetBloc = BudgetBloc();

  final FocusNode _focus = FocusNode();
  TextEditingController budgetController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String userEmail = '';
  bool isSkippedUser = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
      }
    });
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    budgetController.dispose();
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    budgetBloc.context = context;
    return BlocConsumer<BudgetBloc, BudgetState>(
      bloc: budgetBloc,
      listener: (context, state) {},
      builder: (context, state) {
        /* if(state is BudgetDoneErrorState){
          Helper.showToast('Enter your budget');
        }*/
        if (state is BudgetInitial) {
          return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Helper.getBackgroundColor(context),
                  titleSpacing: 10,
                  title: Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.blue,
                            size: 20,
                          )),
                      10.widthBox,
                      Expanded(
                        child: Text(
                          "Hello",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Helper.getTextColor(context)),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    InkWell(
                      onTap: () async {
                        if (budgetController.text.isEmpty) {
                          Helper.showToast('Enter your budget');
                        } else {
                          if (!isSkippedUser) {
                            print("NO skipped");
                            await DatabaseHelper.instance
                                .getProfileData(userEmail)
                                .then((profileData) async {
                              profileData.current_balance =
                                  budgetController.text.toString();
                              profileData.actual_budget =
                                  budgetController.text.toString();
                              await DatabaseHelper.instance
                                  .updateProfileData(profileData);
                              MySharedPreferences.instance.addBoolToSF(
                                  SharedPreferencesKeys.isBudgetAdded, true);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DashBoard()),
                              );
                            });
                          } else {
                            print("SKipped");
                            MySharedPreferences.instance.addStringToSF(
                                SharedPreferencesKeys.skippedUserCurrentBalance,
                                budgetController.text.toString());
                            MySharedPreferences.instance.addStringToSF(
                                SharedPreferencesKeys.skippedUserCurrentIncome,
                                "0");
                            MySharedPreferences.instance.addStringToSF(
                                SharedPreferencesKeys.skippedUserActualBudget,
                                budgetController.text.toString());
                            MySharedPreferences.instance.addBoolToSF(
                                SharedPreferencesKeys.isBudgetAdded, true);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DashBoard()),
                            );
                          }
                        }
                        //budgetBloc.add(BudgetDoneEvent(budgetController.text));
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                            fontSize: 14, color: Helper.getTextColor(context)),
                      ),
                    ),
                    10.widthBox,
                  ],
                ),
                body: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: Helper.getBackgroundColor(context),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        10.heightBox,
                        SvgPicture.asset(
                          ImageConstanst.icBanner,
                          width: 120,
                          height: 150,
                        ),
                        10.heightBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Follow your plan to avoid unnecessary spending.Set\na budget for the month and try to follow it to\nachieve your financial goals.",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Helper.getTextColor(context)),
                          ),
                        ),
                        20.heightBox,
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "MONTHLY BUDGET",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                          ),
                        ),
                        10.heightBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(children: [
                            Expanded(
                                child: CustomBoxTextFormField(
                                    controller: budgetController,
                                    onChanged: (val) {
                                      budgetBloc.add(BudgetTextChangedEvent(
                                          budgetController.text));
                                    },
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        bottomLeft: Radius.circular(5)),
                                    keyboardType: TextInputType.number,
                                    hintText: "Enter your budget",
                                    fillColor: Helper.getCardColor(context),
                                    borderColor: Colors.transparent,
                                    textStyle: TextStyle(
                                        color: Helper.getTextColor(context)),
                                    padding: 15,
                                    horizontalPadding: 5,
                                    //focusNode: _focus,
                                    validator: (value) {
                                      return null;
                                    })),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14.2, horizontal: 5),
                              decoration: BoxDecoration(
                                  color: Helper.getCardColor(context),
                                  border: Border(
                                    left: BorderSide(
                                      color: Helper.getCardColor(context),
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      bottomRight: Radius.circular(5))),
                              child: Row(
                                children: [
                                  5.widthBox,
                                  const Text("\$",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.blue)),
                                  5.widthBox,
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 14,
                                    color: Helper.getTextColor(context),
                                  )
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                )),
          );
        }
        return Container();
      },
    );
  }
}
