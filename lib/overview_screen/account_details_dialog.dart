
import 'package:flutter/material.dart';
import 'package:expense_manager/db_models/accounts_model.dart';

import '../utils/helper.dart';

class AccountDetailsDialog extends StatefulWidget {
  final List<AccountsModel?> accountsList;

  const AccountDetailsDialog({super.key, required this.accountsList});

  @override
  State<AccountDetailsDialog> createState() => _AccountDetailsDialogState();
}

class _AccountDetailsDialogState extends State<AccountDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:   Helper.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 8),
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
                return InkWell(
                  onTap: () {},
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
                            color: Helper.getBackgroundColor(context),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Center(
                            child: Text(
                              Helper.getShortName(
                                widget.accountsList[index]!.account_name!.split(' ').first,
                                widget.accountsList[index]!.account_name!.split(' ').length > 1
                                    ? widget.accountsList[index]!.account_name!.split(' ').last
                                    : "",
                              ),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.accountsList[index]!.account_name!,
                            style: TextStyle(
                              color: Helper.getTextColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  thickness: 0,
                  height: 5,
                  color: Colors.transparent,
                );
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

