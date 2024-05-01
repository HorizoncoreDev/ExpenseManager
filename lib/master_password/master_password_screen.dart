import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/views/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MyDialog {
  TextEditingController generateMasterPasswordController = TextEditingController();
  TextEditingController masterPasswordController = TextEditingController();
  String encodedPassword = "";
  String decodedPassword = "";
  String encryptedPassword = "";
  bool isMPGenerate = false;
  String getMasterPassword = "";
  List<List<dynamic>> data = [];

  Future<void> showMasterPasswordDialog({required BuildContext context}) async {
    MySharedPreferences.instance.getBoolValuesSF(SharedPreferencesKeys.isMasterPasswordGenerated).then((value) {
      if (value != null) isMPGenerate = value;
    });
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
                            controller: masterPasswordController,
                            onChanged: (val) {},
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                            keyboardType: TextInputType.text,
                            hintText: "Password",
                            maxLength: 8,
                            minLines: 1,
                            obscureText: true,
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
                        if (isMPGenerate)...[
                          10.heightBox,
                          InkWell(
                            onTap: () {},
                            child: Text('Forgot Password?'),
                          ),
                        ]
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
                        if(isMPGenerate)
                        TextButton(
                          onPressed: () async {
                            FirebaseDatabase.instance.reference()
                                .child('masterPasswords')
                                .child(FirebaseAuth.instance.currentUser!.uid).onValue
                                .listen((event) async {
                              DataSnapshot dataSnapshot = event.snapshot;
                              Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
                              print("value is ${values['masterPassword']}");
                              getMasterPassword = await decryptData(values['masterPassword']);
                              print("value is $getMasterPassword");
                              if (masterPasswordController.text.isEmpty) {
                                Helper.showToast("Please enter password");
                              } else if (masterPasswordController.text.length < 8) {
                                Helper.showToast("Please enter 8 characters password");
                              }else if (masterPasswordController.text != getMasterPassword) {
                                print("value iss $getMasterPassword");
                                print("value isss ${masterPasswordController.text}");
                                Helper.showToast("You entered wrong password");
                              } else if(masterPasswordController.text == getMasterPassword){
                                Helper.showToast("Password submitted successfully");
                                Navigator.pop(context);
                                // exportCSVFile();
                                final rawData = await rootBundle.loadString(ImageConstanst.tasksCSV);
                                List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
                                setState(() {
                                  data = listData;
                                });
                                print("Data is $data");
                              }
                            });
                          },
                          child: const Text('Submit'),
                        ),
                          if(!isMPGenerate)
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
                                              obscureText: true,
                                              keyboardType: TextInputType.text,
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
                                                Helper.showToast("Please enter 8 characters password");
                                              } else {
                                                await generatingPassword();
                                                Helper.showToast("Password is generated successfully");
                                                MySharedPreferences.instance.addBoolToSF(
                                                    SharedPreferencesKeys.isMasterPasswordGenerated, true);
                                                Navigator.pop(context);
                                                MySharedPreferences.instance
                                                    .getBoolValuesSF(SharedPreferencesKeys.isMasterPasswordGenerated)
                                                    .then((value) {
                                                  if (value != null) {
                                                    setState((){
                                                      isMPGenerate = value;
                                                    });
                                                  }
                                                });
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
    decodedPassword = utf8.decode(base64.decode(masterPassword));
    return decodedPassword;
  }

  Future<void> generatingPassword() async {
    String masterPassword = generateMasterPasswordController.text;
    encryptedPassword = _encrypt(masterPassword);
    print("EP is $encryptedPassword");
    final DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    await dbRef
        .child('masterPasswords')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .set({'masterPassword': encryptedPassword});
  }

  void exportCSVFile() async {
    String csvData = await DatabaseHelper.exportAllToCSV();

    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/tasks.csv';

    final File file = File(path);
    await file.writeAsString(csvData);

    Helper.showToast('CSV file has been exported to $path');
    print("file path $path");
  }



}
