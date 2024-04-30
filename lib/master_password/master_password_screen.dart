import 'dart:convert';
import 'package:expense_manager/utils/extensions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/views/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDialog {
  TextEditingController generateMasterPasswordController =
  TextEditingController();
  TextEditingController masterPasswordController = TextEditingController();
  String encodedPassword = "";
  String decodedPassword = "";
  bool isPasswordGenerated = false;

  void showMasterPasswordDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {
                return AlertDialog(
                  title: const Text('Master Password'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Expanded(
                          child: CustomBoxTextFormField(
                            controller: generateMasterPasswordController,
                            onChanged: (val) {},
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                            keyboardType: TextInputType.number,
                            hintText: "Password",
                            fillColor: Helper.getCardColor(context),
                            borderColor: Colors.transparent,
                            textStyle: TextStyle(
                              color: Helper.getTextColor(context),
                            ),
                            padding: 15,
                            horizontalPadding: 5,
                            //focusNode: _focus,
                            validator: (value) {
                              return null;
                            },
                          ),
                        ),
                        if (isPasswordGenerated) 10.heightBox,
                        if (isPasswordGenerated)
                          InkWell(
                            onTap: () {},
                            child: Text('Forgot Password?'),
                          ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                        if (!isPasswordGenerated)
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Generate Password'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Expanded(
                                            child: CustomBoxTextFormField(
                                              controller: generateMasterPasswordController,
                                              onChanged: (val) async {},
                                              maxLength: 8,
                                              minLines: 1,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                bottomLeft: Radius.circular(5),
                                              ),
                                              keyboardType: TextInputType.number,
                                              hintText: "Create master password",
                                              fillColor: Helper.getCardColor(context),
                                              borderColor: Colors.transparent,
                                              textStyle: TextStyle(
                                                color: Helper.getTextColor(context),
                                              ),
                                              padding: 15,
                                              horizontalPadding: 5,
                                              validator: (value) {
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Close'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (generateMasterPasswordController.text.isEmpty) {
                                                Helper.showToast("Please enter password");
                                              } else if (generateMasterPasswordController.text.length < 8) {
                                                Helper.showToast("Please enter 8 digit password");
                                              } else {
                                                await generatingPassword();
                                                Helper.showToast("Password is generated successfully");
                                                setState((){
                                                  isPasswordGenerated = true;
                                                });
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text('Submit'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Generate'),
                          ),
                      ],
                    ),
                  ],
                );
              },

            );
      },
    );
  }

  String _encrypt(String masterPassword) {
    encodedPassword = base64Encode(utf8.encode(masterPassword));
    return encodedPassword;
  }

  String decryptData(String masterPassword) {
    decodedPassword = utf8.decode(base64.decode(encodedPassword));
    return decodedPassword;
  }

  Future<void> generatingPassword() async {
    String masterPassword = generateMasterPasswordController.text;
    final encryptedPassword = _encrypt(masterPassword);
    final decryptPassword = decryptData(masterPassword);
    print("DP is $decryptPassword");
    print("EP is $encryptedPassword");
    final DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    await dbRef
        .child('masterPasswords')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .set({'masterPassword': encryptedPassword});

  }
}
