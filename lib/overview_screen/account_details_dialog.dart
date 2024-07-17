import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:expense_manager/db_models/accounts_model.dart';
import 'package:get/get.dart';

import '../db_service/database_helper.dart';
import '../utils/global.dart';
import '../utils/helper.dart';
import '../utils/my_shared_preferences.dart';

class AccountDetailsDialog extends StatefulWidget {
  final List<AccountsModel?> accountsList;

  const AccountDetailsDialog({Key? key, required this.accountsList}) : super(key: key);

  @override
  State<AccountDetailsDialog> createState() => _AccountDetailsDialogState();
}

class _AccountDetailsDialogState extends State<AccountDetailsDialog> {
  String userName = '';
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    userName = await MySharedPreferences.instance.getStringValuesSF(SharedPreferencesKeys.currentUserName) ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Helper.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Account Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: widget.accountsList.length,
              itemBuilder: (context, index) {
                final account = widget.accountsList[index]!;
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      MySharedPreferences.instance.addIntToSF(SharedPreferencesKeys.selectedAccountIndex, selectedIndex);
                      MySharedPreferences.instance.addStringToSF(SharedPreferencesKeys.currentUserName, account.account_name);
                      MySharedPreferences.instance.addStringToSF(SharedPreferencesKeys.currentAccountKey, account.key);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Helper.getCardColor(context),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                            Helper.getBackgroundColor(context),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)),
                          ),
                          child: Center(
                            child: Text(
                              Helper.getShortName(
                                  account.account_name!
                                      .split(' ')
                                      .first ??
                                      "",
                                  account.account_name!
                                      .split(' ')
                                      .length >
                                      1
                                      ? account.account_name!
                                      .split(' ')
                                      .last
                                      : ""),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            account.account_name!,
                            style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        /*if (selectedIndex == index)
                          SvgPicture.asset(
                            'asset/images/ic_accept.svg',
                            color: Colors.green,
                            height: 24,
                            width: 24,
                          ),*/
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(thickness: 0, height: 10, color: Colors.transparent);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Close",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
