import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/views/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int catType = 1;
  bool isSkippedUser = false;
  // FirebaseAuth? _firebaseAuth;
  String email = "";

  Future<void> showMasterPasswordDialog({required BuildContext context, required bool export}) async {
    MySharedPreferences.instance.getBoolValuesSF(
        SharedPreferencesKeys.isMasterPasswordGenerated).then((value) {
      if (value != null) isMPGenerate = value;
    });

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
        email = value;
      }
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setState) {
            return AlertDialog(
              title: const Text('Master Password'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    CustomBoxTextFormField(
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
                    if (isMPGenerate)...[
                      10.heightBox,
                      InkWell(
                        onTap: () async {
                        /*  try {
                            await _firebaseAuth!.sendPasswordResetEmail(email: email);
                          } on FirebaseAuthException catch (err) {
                            throw Exception(err.message.toString());
                          } catch (err) {
                            throw Exception(err.toString());
                          }*/
                          createMP(context, setState);
                        },
                        child: const Text('Forgot Password?'),
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
                          FirebaseDatabase.instance
                              .ref()
                              .child('master_passwords_table')
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .onValue
                              .listen((event) async {
                            DataSnapshot dataSnapshot = event.snapshot;
                            Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
                            print("value is ${values['master_password']}");
                            getMasterPassword = await decryptData(values['master_password']);
                            print("value is $getMasterPassword");
                            if (masterPasswordController.text.isEmpty) {
                              Helper.showToast("Please enter password");
                            } else
                            if (masterPasswordController.text.length < 8) {
                              Helper.showToast(
                                  "Please enter 8 characters password");
                            } else if (masterPasswordController.text !=
                                getMasterPassword) {
                              print("value iss $getMasterPassword");
                              print("value isss ${masterPasswordController
                                  .text}");
                              Helper.showToast("You entered wrong password");
                            } else if (masterPasswordController.text ==
                                getMasterPassword) {
                              Helper.showToast(
                                  "Password submitted successfully");
                              if(export){
                                Navigator.pop(context);
                                exportCSVFile();
                              }
                              else {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['csv'],
                                );
                                if (result != null) {
                                  PlatformFile file = result.files.first;
                                  String? rawData = await File(file.path!).readAsString();
                                  List<List<dynamic>> listData = const CsvToListConverter().convert(rawData!);
                                  setState(() {
                                    data = listData;
                                  });
                                  print("Data is $data");
                                  Navigator.pop(context);
                                  addDataIntoTransactionTable(context);
                                } else {
                                  print("File selection canceled");
                                }
                              }
                            }
                          });
                        },
                        child: const Text('Submit'),
                      ),
                    if(!isMPGenerate)
                      TextButton(
                        onPressed: () {
                          createMP(context, setState);
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
        .child('master_passwords_table')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .set({'master_password': encryptedPassword});
  }

  void exportCSVFile() async {
    String csvData = await DatabaseHelper.exportAllToCSV();
    String name = "";
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userName)
        .then((value) {
      if (value != null) {
        List<String> names = value.split(" ") ?? [];
        name = names.isNotEmpty ? names[0].toLowerCase() : "";
      }
    });

    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String filePath = '/storage/emulated/0/Download/${name}_$date.csv';
    final File file = File(filePath);
    await file.writeAsString(csvData);
  }

  void addDataIntoTransactionTable(BuildContext context) async {
    final reference = FirebaseDatabase.instance
        .reference()
        .child(transaction_table);
    var newPostRef = reference.push();
    for (int i = 1; i < data.length; i++) {
      /// Start from index 1 to skip the header row

      String categoryName = data[i][3].toString();
      int categoryType = data[i][4];
      int transactionType = data[i][7];
      int amount = data[i][2];
      String email = data[i][1].toString();

      int? catIds = await DatabaseHelper().getCategoryID(categoryName, categoryType, transactionType);
      String? catIcon = await DatabaseHelper().getCategoryIcon(catIds, /*categoryName*/ categoryType, transactionType);
      // int? catColorHex = await DatabaseHelper().getCategoryColor(/*catIds,*/ categoryName, categoryType, transactionType);
      // Color catColor = catColorHex != null ? Color(catColorHex) : Colors.blueAccent;
      print("Id is $catIds");


      TransactionModel transactionModel = TransactionModel(
        key: newPostRef.key,
        member_id: data[i][0],
        member_email: email,
        amount: amount,
        expense_cat_id: categoryType == 0 && transactionType == 1 ? catIds : -1,
        sub_expense_cat_id: categoryType == 1 && transactionType == 1 ? catIds : -1,
        income_cat_id: categoryType == 0 && transactionType == 2 ? catIds : -1,
        sub_income_cat_id: categoryType == 1 && transactionType == 2 ? catIds : -1,
        cat_name: categoryName,
        cat_type: categoryType,
        cat_color: Colors.blueAccent,
        cat_icon: catIcon ?? "ic_card",
        payment_method_id: data[i][5] == "Cash" ? 1
            : data[i][5] == "Online" ? 2
            : data[i][5] == "Card" ? 3
            : 1,
        payment_method_name: data[i][5],
        status: 1,
        transaction_date: data[i][6].toString(),
        transaction_type: transactionType,
        description: data[i][8].toString(),
        currency_id: AppConstanst.rupeesCurrency,
        receipt_image1: data[i][9].toString() ?? "",
        receipt_image2: data[i][10].toString() ?? "",
        receipt_image3: data[i][11].toString() ?? "",
        created_at: DateTime.now().toString(),
        last_updated: DateTime.now().toString(),
      );

      await DatabaseHelper().insertTransactionData(transactionModel).then((value) async {
        if (value != null) {
            if (isSkippedUser) {
              if (transactionType == AppConstanst.spendingTransaction) {
                MySharedPreferences.instance
                    .getStringValuesSF(
                    SharedPreferencesKeys.skippedUserCurrentBalance)
                    .then((value) {
                  if (value != null) {
                    String updateBalance =
                    (int.parse(value) - amount)
                        .toString();
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentBalance,
                        updateBalance);
                  }
                });
              } else {
                MySharedPreferences.instance
                    .getStringValuesSF(
                    SharedPreferencesKeys.skippedUserCurrentIncome)
                    .then((value) {
                  if (value != null) {
                    String updateBalance =
                    (int.parse(value) + amount)
                        .toString();
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentIncome,
                        updateBalance);
                  }
                });
              }
            } else {
              await DatabaseHelper.instance.getProfileData(email)
                  .then((profileData) async {
                if (transactionType == AppConstanst.spendingTransaction) {
                  profileData!.current_balance =
                      (int.parse(profileData.current_balance!) -
                          amount)
                          .toString();
                } else {
                  profileData!.current_income =
                      (int.parse(profileData.current_income!) +
                          amount)
                          .toString();
                }
                await DatabaseHelper.instance.updateProfileData(profileData);
              });
            }
          // }
        }
      });
      print("Data is inserted");
    }
  }

  void createMP(BuildContext context, void Function(void Function() p1) setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generate Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                CustomBoxTextFormField(
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
                  fillColor: Helper.getCardColor(
                      context),
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
                    if (generateMasterPasswordController
                        .text.isEmpty) {
                      Helper.showToast(
                          "Please enter password");
                    } else
                    if (generateMasterPasswordController
                        .text.length < 8) {
                      Helper.showToast(
                          "Please enter 8 characters password");
                    } else {
                      await generatingPassword();
                      Helper.showToast(
                          "Password is generated successfully");
                      MySharedPreferences.instance
                          .addBoolToSF(
                          SharedPreferencesKeys
                              .isMasterPasswordGenerated,
                          true);
                      Navigator.pop(context);
                      MySharedPreferences.instance
                          .getBoolValuesSF(
                          SharedPreferencesKeys
                              .isMasterPasswordGenerated)
                          .then((value) {
                        if (value != null) {
                          setState(() {
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
  }
}
