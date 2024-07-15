import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:expense_manager/db_models/multiple_email_model.dart';
import 'package:expense_manager/db_models/receiver_email_data.dart';
import 'package:expense_manager/db_models/request_model.dart';
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/drive_upload_import/drive_service.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/views/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../db_models/profile_model.dart';

class MasterPasswordDialog {
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
  final _driveService = DriveService();
  String? fileId;
  String fileName = "";
  String userEmail = "", currentUserEmail = "";
  List<TransactionModel> transactions = [];
  // ProfileModel profileModel = ProfileModel();

  Future<void> showMasterPasswordDialog({required BuildContext context, required bool export, required String backupType}) async {
    MySharedPreferences.instance.getBoolValuesSF(
        SharedPreferencesKeys.isMasterPasswordGenerated).then((value) {
      if (value != null) isMPGenerate = value;
    });

    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) async {
      if (value != null) {
        userEmail = value;
      }
    });

    MySharedPreferences.instance
        .getBoolValuesSF(SharedPreferencesKeys.isSkippedUser)
        .then((value) {
      if (value != null) {
        isSkippedUser = value;
      }
    });

    FirebaseDatabase.instance
        .ref()
        .child('master_passwords_table')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .onValue
        .listen((event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
      getMasterPassword = values['master_password'];
      if(getMasterPassword.isNotEmpty){
        isMPGenerate = true;
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setState) {
            return AlertDialog(
              title: Text(LocaleKeys.masterPassword.tr),
              backgroundColor: Helper.getCardColor(context),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    CustomBoxTextFormField(
                      decoration: InputDecoration(
                          counterText: ""
                      ),
                      controller: masterPasswordController,
                      onChanged: (val) {},
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                      keyboardType: TextInputType.text,
                      hintText: LocaleKeys.password.tr,
                      maxLength: 8,
                      minLines: 1,
                      obscureText: true,
                      fillColor: Colors.black.withOpacity(0.6),
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
                          createMP(context, setState);
                        },
                        child: Text('${LocaleKeys.forgotPassword.tr}?'),
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
                      child: Text(LocaleKeys.close.tr),
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
                              Helper.showToast(LocaleKeys.enterPassword.tr);
                            } else
                            if (masterPasswordController.text.length < 8) {
                              Helper.showToast(
                                  LocaleKeys.eightCharacterPw.tr);
                            } else if (masterPasswordController.text !=
                                getMasterPassword) {
                              print("value iss $getMasterPassword");
                              print("value isss ${masterPasswordController
                                  .text}");
                              Helper.showToast(LocaleKeys.wrongPassword.tr);
                            } else if (masterPasswordController.text ==
                                getMasterPassword) {
                              Helper.showToast(
                                  LocaleKeys.submitSuccessfully.tr);
                              if(export){
                                Navigator.pop(context);
                                if(backupType == "CSV"){
                                  exportCSVFile(userEmail);
                                }
                                else if(backupType == "DRIVE"){
                                  exportFileOnDrive(context);
                                }
                                else if(backupType == "DB"){

                                }
                                else{
                                  Helper.showToast(LocaleKeys.selectBackupType.tr);
                                }
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
                                  print("Data is ${data}");
                                  Navigator.pop(context);

                                  addDataIntoTransactionTable(context);
                                } else {
                                  print("File selection canceled");
                                }
                              }
                            }
                          });
                        },
                        child: Text(LocaleKeys.submit.tr),
                      ),
                    if(!isMPGenerate )
                      TextButton(
                        onPressed: () {
                          createMP(context, setState);
                        },
                        child: Text(LocaleKeys.generate.tr),
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

  void exportCSVFile(String userEmail) async {
    String csvData = await DatabaseHelper.exportAllToCSV(userEmail);

    if(csvData.isNotEmpty){
      String name = "";
      MySharedPreferences.instance
          .getStringValuesSF(SharedPreferencesKeys.userName)
          .then((value) async {
        if (value != null) {
          name = value;
          String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
          String filePath = '/storage/emulated/0/Download/${name}_$date.csv';
          final File file = File(filePath);
          await file.writeAsString(csvData);
          Helper.showToast('${LocaleKeys.csvExportedTo.tr} $filePath');
          print("file path $filePath");
        }
      });
    }

    MultipleEmailModel multipleEmailModel = await DatabaseHelper.exportAccessEmailDataToCSV(userEmail);
    if(multipleEmailModel.csv.isNotEmpty){
      String date = DateFormat('dd-MM-yyyy').format(DateTime.now());

      for (var receiverName in multipleEmailModel.receiversName) {
        String filePath = '/storage/emulated/0/Download/${receiverName}_$date.csv';
        final File file = File(filePath);
        await file.writeAsString(multipleEmailModel.csv[receiverName]!);
        Helper.showToast('${LocaleKeys.csvExportedTo.tr} $filePath');
        print("file path $filePath");
      }
    }
  }

  Future<Map<String, String?>> exportFileOnDrive(BuildContext context) async {
    String csvData = await DatabaseHelper.exportAllToCSV(userEmail);
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
    final Directory? directory = await getExternalStorageDirectory();
    final String path = directory!.path;
    String filePath = '/storage/emulated/0/Download/${name}_$date.csv';
    fileName = "${name}_$date.csv";
    final File file = File(filePath);
    await file.writeAsString(csvData);

    Helper.showToast('${LocaleKeys.csvExportedTo.tr} $path');
    print("file path $path");

    String? fileId = await uploadDrive(context, filePath, fileName);
    if (fileId != null) {
      MySharedPreferences.instance.addStringToSF("fileId", fileId);
    }
    return {"path": path, "fileId": fileId};
  }

  ///upload file in drive
  Future<String?> uploadDrive(BuildContext context, String filePath, String fileName) async {
    final bool exists = await File(filePath).exists();
    if (!exists) {
      Helper.showToast('${LocaleKeys.fileNotExist.tr}: $filePath');
      return null;
    }
    fileId = await _driveService.uploadFile(fileName, filePath);
    print("upload file id:- $fileId");

    if (fileId != null) {
      Helper.showToast('${LocaleKeys.fileUploadWithId.tr}: $fileId');
      print("'File uploaded successfully with ID: $fileId'");
      return fileId;
    } else {
      Helper.showToast(LocaleKeys.failedUploadGDrive.tr);
      return null;
    }
  }

  ///download file from drive
  Future<void> downloadCsvFileFromDrive(String fileId) async  {
    String dir = (await getExternalStorageDirectory())!.path;

    String downloadedFilePath = '$dir/downloaded_file.csv';

    String? filePath = await _driveService.downloadFile(fileId, downloadedFilePath);

    if (filePath != null) {
      Helper.showToast('${LocaleKeys.fileDownloadAt.tr}: $filePath');
    } else {
      Helper.showToast(LocaleKeys.failedUploadGDrive.tr);
    }
  }


  void addDataIntoTransactionTable(BuildContext context) async {
    List<TransactionModel> importTransactionListData = [];
    int currentBalance=0;
    int currentIncome=0;
    String importEmail = "";
    List<ReceiverEmailData> checkRecEmailList = await DatabaseHelper.getAccessEmails(userEmail);
    Set<String?> receiverEmails = checkRecEmailList.map((e) => e.receiverEmail).toSet();
    for (int i = 1; i < data.length; i++) {
      /// Start from index 1 to skip the header row
      String categoryName = data[i][2].toString();
      int categoryType = data[i][3];
      int transactionType = data[i][6];
      int amount = data[i][1];
      importEmail = data[i][0].toString();
      String transactionKey = data[i][11];

      if (!receiverEmails.contains(importEmail) && importEmail != userEmail) {
        Helper.showToast("You do not have access of this account!");
        continue;
      }
      else {
        List<TransactionModel> existingTransactions = await DatabaseHelper
            .getTransactionsForEmail(importEmail);

        /*bool transactionExists = existingTransactions.any((
            transaction) => transaction.key == transactionKey);
        if (transactionExists) {
          print("Duplicate transaction found, skipping: $transactionKey");
          continue;
        }
        else {*/
          if (transactionType == AppConstanst.spendingTransaction) {
            currentBalance = currentBalance + amount;
          } else {
            currentIncome = currentIncome + amount;
          }
          int? catIds = await DatabaseHelper().getCategoryID(
              categoryName, categoryType, transactionType);
          String? catIcon = await DatabaseHelper().getCategoryIcon(
              catIds!, /*categoryName*/ categoryType, transactionType);

          TransactionModel transactionModel = TransactionModel(
            key: transactionKey,
            member_key: importEmail,
            amount: amount,
            expense_cat_id: categoryType == 0 && transactionType == 1
                ? catIds
                : -1,
            sub_expense_cat_id: categoryType == 1 && transactionType == 1
                ? catIds
                : -1,
            income_cat_id: categoryType == 0 && transactionType == 2
                ? catIds
                : -1,
            sub_income_cat_id: categoryType == 1 && transactionType == 2
                ? catIds
                : -1,
            cat_name: categoryName,
            cat_type: categoryType,
            cat_color: Colors.blueAccent,
            cat_icon: catIcon ?? "ic_card",
            payment_method_id: data[i][4] == "Cash" ? 1
                : data[i][4] == "Online" ? 2
                : data[i][4] == "Card" ? 3
                : 1,
            payment_method_name: data[i][4],
            status: 1,
            transaction_date: data[i][5].toString(),
            transaction_type: transactionType,
            description: data[i][7].toString(),
            currency_id: AppConstanst.rupeesCurrency,
            receipt_image1: data[i][8].toString() ?? "",
            receipt_image2: data[i][9].toString() ?? "",
            receipt_image3: data[i][10].toString() ?? "",
            created_at: DateTime.now().toString(),
            last_updated: DateTime.now().toString(),
          );
          importTransactionListData.add(transactionModel);

          print("Data is inserted");
          print("list is this ${importTransactionListData.length}");
        }
      // }
    }
    final reference = FirebaseDatabase.instance
        .reference()
        .child(profile_table)
        .orderByChild(ProfileTableFields.email)
        .equalTo(importEmail);

    reference.once().then((event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
        dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) async {
          var profileModel = ProfileModel.fromMap(value);

          await DatabaseHelper().insertMultipleTransactions(importTransactionListData,value['key'],isSkippedUser);
          if (value != null) {
            if (isSkippedUser) {
                MySharedPreferences.instance
                    .getStringValuesSF(
                    SharedPreferencesKeys.skippedUserCurrentBalance)
                    .then((value) {
                  if (value != null) {
                    String updateBalance =
                    (int.parse(value) - currentBalance)
                        .toString();
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentBalance,
                        updateBalance);
                  }
                });
                MySharedPreferences.instance
                    .getStringValuesSF(
                    SharedPreferencesKeys.skippedUserCurrentIncome)
                    .then((value) {
                  if (value != null) {
                    String updateBalance =
                    (int.parse(value) + currentIncome)
                        .toString();
                    MySharedPreferences.instance.addStringToSF(
                        SharedPreferencesKeys.skippedUserCurrentIncome,
                        updateBalance);
                  }
                });
            }
            else {
              profileModel.current_balance =
                  (int.parse(profileModel.current_balance!) -
                      currentBalance)
                      .toString();

              profileModel.current_income =
                  (int.parse(profileModel.current_income!) +
                      currentIncome)
                      .toString();

              await DatabaseHelper.instance.updateProfileData(profileModel);
            }
          }
        });
      }
    });
  }
  void createMP(BuildContext context, void Function(void Function() p1) setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.generatePW.tr),
          backgroundColor: Helper.getCardColor(context),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                CustomBoxTextFormField(
                  controller: generateMasterPasswordController,
                  onChanged: (val) async {},
                  maxLength: 8,
                  minLines: 1,
                  decoration: InputDecoration(
                    counterText: ""
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  hintText: LocaleKeys.createMPW.tr,
                  fillColor: Colors.black.withOpacity(0.6),
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
                  child: Text(LocaleKeys.close.tr),
                ),
                TextButton(
                  onPressed: () async {
                    if (generateMasterPasswordController
                        .text.isEmpty) {
                      Helper.showToast(
                          LocaleKeys.enterPassword.tr);
                    } else
                    if (generateMasterPasswordController
                        .text.length < 8) {
                      Helper.showToast(
                          LocaleKeys.eightCharacterPw.tr);
                    } else {
                      await generatingPassword();
                      Helper.showToast(
                          LocaleKeys.passwordGenerate.tr);
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
                  child: Text(LocaleKeys.submit.tr),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}