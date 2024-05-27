import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:expense_manager/db_models/accounts_model.dart';
import 'package:expense_manager/db_models/currency_category_model.dart';
import 'package:expense_manager/db_models/language_category_model.dart';
import 'package:expense_manager/db_models/multiple_email_model.dart';
import 'package:expense_manager/db_models/receiver_email_data.dart';
import 'package:expense_manager/db_models/request_model.dart';
import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/statistics/statistics_screen.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../db_models/expense_category_model.dart';
import '../db_models/expense_sub_category.dart';
import '../db_models/income_category.dart';
import '../db_models/income_sub_category.dart';
import '../db_models/payment_method_model.dart';
import '../db_models/profile_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper.init();

  static DatabaseHelper? _databaseHelper;

  static Database? _database;
  final Map<String, int> monthNameToNumber = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  DatabaseHelper.init();

  DatabaseHelper._createInstance();

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  /// A method that retrieves all the category from the category table.
  Future<List<ExpenseCategory>> categorys() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(expense_category_table);
    return List.generate(
        maps.length, (index) => ExpenseCategory.fromMap(maps[index]));
  }

  Future<void> clearAllTables() async {
    Database db = await instance.database;
    await db.delete(transaction_table);
    await db.delete(profile_table);
    Helper.showToast("All transaction are deleted.");
  }

  /*Future<void> deleteDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}em.db';

    if(await databaseExists(path)){
      await deleteDatabase(path);
      Helper.showToast("Your data is cleared");
    }
    else{
      Helper.showToast("Data does not exist.");
    }
  }*/

  Future<void> clearTransactionTable() async {
    Database db = await instance.database;
    await db.delete(transaction_table);
    Helper.showToast("All transaction are cleared.");
  }

  /// A method that retrieves all the currencyMethod from the currencyCategory table.
  Future<List<CurrencyCategory>> currencyMethods() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(currency_table);
    return List.generate(
        maps.length, (index) => CurrencyCategory.fromMap(maps[index]));
  }

  Future<void> deleteTransactionFromDB(
      TransactionModel transactionModel, bool isSkippedUser) async {
    Database db = await instance.database;
    await db.delete(
      transaction_table,
      where: 'key = ?',
      whereArgs: [transactionModel.key],
    );
    if (!isSkippedUser) {
      final reference =
          FirebaseDatabase.instance.reference().child(transaction_table);
      reference
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child(transactionModel.key!)
          .remove();
    }
  }

  Future<List<TransactionModel>> fetchAllDataForYearMonthsAndCategory(
      String year,
      List<MonthData> months,
      int expenseCatId,
      int incomeCatId,
      String email,
      String key,
      String category,
      bool isSkippedUser) async {
    List<int> selectedMonthNumbers = months
        .map((monthData) => monthNameToNumber[monthData.text])
        .where((monthNumber) => monthNumber != null)
        .map((monthNumber) => monthNumber!)
        .toList();

    if (isSkippedUser) {
      Database db = await database;
      String query = '''SELECT * FROM $transaction_table WHERE ''';

      List<String> conditions = [];

      for (int month in selectedMonthNumbers) {
        conditions
            .add('SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?');
      }

      query +=
          '(${conditions.join(' OR ')})'; // Combine conditions using OR operator
      query +=
          ' AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ${TransactionFields.member_email} = ?';
      List<dynamic> whereArgs = [
        ...selectedMonthNumbers
            .map((month) => month.toString().padLeft(2, '0')),
        year,
        email
      ];

      if (expenseCatId != -1 || incomeCatId != -1) {
        query +=
            ' AND ${TransactionFields.expense_cat_id} = ? AND ${TransactionFields.income_cat_id} = ?';
        whereArgs.add(expenseCatId);
        whereArgs.add(incomeCatId);
      }

      if (category.isNotEmpty) {
        query +=
            ' AND ${TransactionFields.cat_name} LIKE ? COLLATE NOCASE OR ${TransactionFields.description} LIKE ? COLLATE NOCASE';
        whereArgs.add('%$category%');
        whereArgs.add('%$category%');
      }

      query += ' ORDER BY ${TransactionFields.transaction_date} DESC';

      print('object..$query..${whereArgs}');
      try {
        List<Map<String, dynamic>> result = await db.rawQuery(
          query,
          whereArgs,
        );

        return List.generate(
            result.length, (index) => TransactionModel.fromMap(result[index]));
      } catch (e) {
        print('Error fetching data: $e');
        return [];
      }
    } else {
      Completer<List<TransactionModel>> completer =
          Completer<List<TransactionModel>>();
      List<TransactionModel> transactions = [];
      final reference = await FirebaseDatabase.instance
          .reference()
          .child(transaction_table)
          .child(key)
          .orderByChild(TransactionFields.member_email)
          .equalTo(email);

      List<String> months = selectedMonthNumbers
          .map((month) => month.toString().padLeft(2, '0'))
          .toList();

      reference.once().then((value) {
        DataSnapshot dataSnapshot = value.snapshot;
        if (value.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            if (months.contains(value[TransactionFields.transaction_date]
                    .substring(3, 5)) &&
                value[TransactionFields.transaction_date].substring(6, 10) ==
                    year) {
              if ((expenseCatId == -1 ||
                      value[TransactionFields.expense_cat_id] ==
                          expenseCatId) &&
                  (incomeCatId == -1 ||
                      value[TransactionFields.income_cat_id] == incomeCatId) &&
                  (category.isEmpty ||
                      value[TransactionFields.cat_name]
                          .toLowerCase()
                          .contains(category.toLowerCase()) ||
                      value[TransactionFields.description]
                          .toLowerCase()
                          .contains(category.toLowerCase()))) {
                transactions.add(TransactionModel.fromMap(value));
              }
            }
          });
          transactions.sort(
              (a, b) => b.transaction_date!.compareTo(a.transaction_date!));
        }
        completer.complete(transactions);
      }).catchError((error) {
        completer.completeError(error);
      });

      return completer.future;
    }
  }

  /// Get transaction data for current month
  Future<List<TransactionModel>> fetchDataForCurrentMonth(
      int transactionType, String email, String key, bool isSkippedUser) async {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;
    if (isSkippedUser) {
      Database db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        transaction_table,
        where: 'SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?'
            ' AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) =?'
            ' AND ${TransactionFields.transaction_type} = ?'
            ' AND ${TransactionFields.member_email} = ?',
        whereArgs: [
          (currentMonth.toString().padLeft(2, '0')),
          (currentYear.toString()),
          transactionType,
          email,
        ],
        orderBy: '${TransactionFields.transaction_date} DESC',
      );

      return List.generate(
          result.length, (index) => TransactionModel.fromMap(result[index]));
    } else {
      Completer<List<TransactionModel>> completer =
          Completer<List<TransactionModel>>();
      List<TransactionModel> transactions = [];
      final reference = await FirebaseDatabase.instance
          .ref()
          .child(transaction_table)
          .child(key)
          .orderByChild(TransactionFields.member_email)
          .equalTo(email);
      reference.once().then((value) {
        DataSnapshot dataSnapshot = value.snapshot;
        if (value.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            DateTime transactionDate = DateFormat('dd/MM/yyyy HH:mm')
                .parse(value[TransactionFields.transaction_date]);

            if (value[TransactionFields.transaction_type] == transactionType &&
                transactionDate.month == currentMonth &&
                transactionDate.year == currentYear) {
              transactions.add(TransactionModel.fromMap(value));
            }
          });
        }
        completer.complete(transactions);
      }).catchError((error) {

        completer.completeError(error);
      });

      return completer.future;
    }
  }

  Future<List<TransactionModel>> fetchDataForYearMonthAndCategory(
      String year,
      String monthName,
      int expenseCatId,
      int incomeCatId,
      String email,
      String key,
      int transactionType,
      String category,
      bool isSkippedUser) async {
    if (isSkippedUser) {
      Database db = await database;

      String query = '''SELECT * FROM $transaction_table WHERE ''';

      int? selectedMonthNumber = monthNameToNumber[monthName];
      if (selectedMonthNumber != null) {
        query += 'SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?';
      }

      query +=
          ' AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ${TransactionFields.member_email} = ? AND ${TransactionFields.transaction_type} = ?';

      List<dynamic> whereArgs = [
        if (selectedMonthNumber != null)
          selectedMonthNumber.toString().padLeft(2, '0'),
        year,
        email,
        transactionType
      ];

      if (expenseCatId == -1 && incomeCatId != -1) {
        query += ' AND ${TransactionFields.income_cat_id} = ?';
        whereArgs.add(incomeCatId);
      } else if (expenseCatId != -1 && incomeCatId == -1) {
        query += ' AND ${TransactionFields.expense_cat_id} = ?';
        whereArgs.add(expenseCatId);
      } else if (expenseCatId != -1 && incomeCatId != -1) {
        query +=
            ' AND ${TransactionFields.expense_cat_id} = ? AND ${TransactionFields.income_cat_id} = ?';
        whereArgs.add(expenseCatId);
        whereArgs.add(incomeCatId);
      }

      if (category.isNotEmpty) {
        query +=
            ' AND (${TransactionFields.cat_name} LIKE ? COLLATE NOCASE OR ${TransactionFields.description} LIKE ? COLLATE NOCASE)';
        whereArgs.add('%$category%');
        whereArgs.add('%$category%');
      }

      query += ' ORDER BY ${TransactionFields.transaction_date} DESC';

      print('object. Arguments...${whereArgs}');
      try {
        List<Map<String, dynamic>> result = await db.rawQuery(
          query,
          whereArgs,
        );
        print("Query result.....${result.toString()}");
        return List.generate(
            result.length, (index) => TransactionModel.fromMap(result[index]));
      } catch (e) {
        print('Error fetching data: $e');
        return [];
      }
    } else {
      Completer<List<TransactionModel>> completer =
          Completer<List<TransactionModel>>();
      List<TransactionModel> transactions = [];
      final reference = await FirebaseDatabase.instance
          .reference()
          .child(transaction_table)
          .child(key)
          .orderByChild(TransactionFields.member_email)
          .equalTo(email);

      int? selectedMonthNumber = monthNameToNumber[monthName];

      reference.once().then((value) {
        DataSnapshot dataSnapshot = value.snapshot;
        if (value.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            if (selectedMonthNumber ==
                    value['transaction_date'].substring(3, 5) &&
                value[TransactionFields.transaction_date].substring(6, 10) ==
                    year &&
                value[TransactionFields.transaction_type] == transactionType &&
                ((expenseCatId == -1 && incomeCatId == -1) ||
                    (expenseCatId != -1 &&
                        value[TransactionFields.expense_cat_id] ==
                            expenseCatId) ||
                    (incomeCatId != -1 &&
                        value[TransactionFields.income_cat_id] ==
                            incomeCatId)) &&
                (category.isEmpty ||
                    value[TransactionFields.cat_name]
                        .toLowerCase()
                        .contains(category.toLowerCase()) ||
                    value[TransactionFields.description]
                        .toLowerCase()
                        .contains(category.toLowerCase()))) {
              transactions.add(TransactionModel.fromMap(value));
            }
          });
          // Sort transactions by transaction date in descending order
          transactions.sort(
              (a, b) => b.transaction_date!.compareTo(a.transaction_date!));
        }
        completer.complete(transactions);
      }).catchError((error) {
        completer.completeError(error);
      });

      return completer.future;
    }
  }

  Future<List<TransactionModel>> fetchDataForYearMonthsAndCategory(
      String year,
      List<MonthData> months,
      int expenseCatId,
      int incomeCatId,
      String email,
      String key,
      int transactionType,
      String category,
      bool isSkippedUser) async {
    List<int> selectedMonthNumbers = months
        .map((monthData) => monthNameToNumber[monthData.text])
        .where((monthNumber) => monthNumber != null)
        .map((monthNumber) => monthNumber!)
        .toList();
    if (isSkippedUser) {
      Database db = await database;

      String query = '''SELECT * FROM $transaction_table WHERE ''';

      List<String> conditions = [];
      List<dynamic> whereArgs = [];
      for (int month in selectedMonthNumbers) {
        conditions
            .add('SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?');
      }

      query +=
          '(${conditions.join(' OR ')})'; // Combine conditions using OR operator
      query +=
          ' AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ${TransactionFields.member_email} = ? AND ${TransactionFields.transaction_type} = ?';

      whereArgs = [
        ...selectedMonthNumbers
            .map((month) => month.toString().padLeft(2, '0')),
        year,
        email,
        transactionType
      ];

      if (expenseCatId == -1 && incomeCatId != -1) {
        query += ' AND ${TransactionFields.income_cat_id} = ?';
        whereArgs.add(incomeCatId);
      } else if (expenseCatId != -1 && incomeCatId == -1) {
        query += ' AND ${TransactionFields.expense_cat_id} = ?';
        whereArgs.add(expenseCatId);
      } else if (expenseCatId != -1 && incomeCatId != -1) {
        query +=
            ' AND ${TransactionFields.expense_cat_id} = ? AND ${TransactionFields.income_cat_id} = ?';
        whereArgs.add(expenseCatId);
        whereArgs.add(incomeCatId);
      }

      if (category.isNotEmpty) {
        query +=
            ' AND (${TransactionFields.cat_name} LIKE ? COLLATE NOCASE OR ${TransactionFields.description} LIKE ? COLLATE NOCASE)';
        whereArgs.add('%$category%');
        whereArgs.add('%$category%');
      }

      query += ' ORDER BY ${TransactionFields.transaction_date} DESC';

      print('object.  query...${query}');
      print('object.  Arguments...${whereArgs}');
      try {
        List<Map<String, dynamic>> result = await db.rawQuery(
          query,
          whereArgs,
        );
        return List.generate(
            result.length, (index) => TransactionModel.fromMap(result[index]));
      } catch (e) {
        print('Error fetching data: $e');
        return [];
      }
    } else {
      Completer<List<TransactionModel>> completer =
          Completer<List<TransactionModel>>();
      List<TransactionModel> transactions = [];
      final reference = await FirebaseDatabase.instance
          .reference()
          .child(transaction_table)
          .child(key)
          .orderByChild(TransactionFields.member_email)
          .equalTo(email);

      List<String> months = selectedMonthNumbers
          .map((month) => month.toString().padLeft(2, '0'))
          .toList();
      reference.once().then((value) {
        DataSnapshot dataSnapshot = value.snapshot;
        if (value.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            if (months[0] == value['transaction_date'].substring(3, 5) &&
                value[TransactionFields.transaction_date].substring(6, 10) ==
                    year &&
                value[TransactionFields.transaction_type] == transactionType &&
                ((expenseCatId == -1 && incomeCatId == -1) ||
                    (expenseCatId != -1 &&
                        value[TransactionFields.expense_cat_id] ==
                            expenseCatId) ||
                    (incomeCatId != -1 &&
                        value[TransactionFields.income_cat_id] ==
                            incomeCatId)) &&
                (category.isEmpty ||
                    value[TransactionFields.cat_name]
                        .toLowerCase()
                        .contains(category.toLowerCase()) ||
                    value[TransactionFields.description]
                        .toLowerCase()
                        .contains(category.toLowerCase()))) {
              transactions.add(TransactionModel.fromMap(value));
            }
          });
          // Sort transactions by transaction date in descending order
          transactions.sort(
              (a, b) => b.transaction_date!.compareTo(a.transaction_date!));
        }
        completer.complete(transactions);
      }).catchError((error) {
        completer.completeError(error);
      });

      return completer.future;
    }
  }

  Future<String?> getCategoryIcon(/*dynamic categoryId, */ int categoryName,
      int categoryType, int transactionType) async {
    String tableName = "";
    String fetchingIcon = "";
    String fetchingName = "";

    if (transactionType == AppConstanst.incomeTransaction) {
//   if (categoryType == AppConstanst.mainCategory) {
      tableName = income_category_table;
      fetchingIcon = CategoryFields.path;
      fetchingName = CategoryFields.id;
    } else {
      tableName = expense_category_table;
      fetchingIcon = ExpenseCategoryField.icons;
      fetchingName = ExpenseCategoryField.id;
    }
// }
/*else{
        tableName = spending_sub_category_table;
        fetchingIcon = ExpenseCategoryField.icons;
        fetchingName = ExpenseSubCategoryFields.name;
      }
    }*/ /*else {
      if (categoryType == 0) {
        tableName = income_category_table;
        fetchingIcon = CategoryFields.path;
        fetchingName = CategoryFields.name;
      }
    }*/

    List<Map<String, dynamic>> result;

/* if (categoryId != null) {
      result = await _database!.query(
        tableName,
        columns: [fetchingIcon],
        where: '${ExpenseCategoryField.id} = ?',
        whereArgs: [categoryId],
      );
    } else {*/
    result = await _database!.query(
      tableName,
      columns: [fetchingIcon],
      where: '$fetchingName = ?',
      whereArgs: [categoryName],
    );
// }

    if (result.isNotEmpty) {
      return result.first[fetchingIcon];
    } else {
      return null; // Return null if category icon is not found
    }
  }

  Future<int> getCategoryID(
      String categoryName, int categoryType, int transactionType) async {
    String tableName = "";
    String fetchingId = "";
    String fetchingName = "";

    if (transactionType == AppConstanst.spendingTransaction) {
      if (categoryType == 0) {
        tableName = expense_category_table;
        fetchingId = ExpenseCategoryField.id;
        fetchingName = ExpenseCategoryField.name;
      } else {
        tableName = spending_sub_category_table;
        fetchingId = ExpenseSubCategoryFields.id;
        fetchingName = ExpenseSubCategoryFields.name;
      }
    } else {
      if (categoryType == 0) {
        tableName = income_category_table;
        fetchingId = CategoryFields.id;
        fetchingName = CategoryFields.name;
      } else {
        tableName = income_sub_category_table;
        fetchingId = IncomeSubCategoryFields.id;
        fetchingName = IncomeSubCategoryFields.name;
      }
    }
    List<Map<String, dynamic>> result = await _database!.query(
      tableName,
      columns: [fetchingId],
      where: '$fetchingName = ?',
      whereArgs: [categoryName],
    );

    if (result.isNotEmpty) {
      print(result);
      return result.first[fetchingId];
    } else {
      return -1; // or any other default value you prefer
    }
  }

  /// A method that retrieves all the IncomeCategory from the IncomeCategory table.
  Future<List<IncomeCategory>> getIncomeCategory() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(income_category_table);
    return List.generate(
        maps.length, (index) => IncomeCategory.fromMap(maps[index]));
  }

  /// A method that retrieves all the income sub category from the income sub table.
  Future<List<IncomeSubCategory>> getIncomeSubCategory(int categoryId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      income_sub_category_table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(
        maps.length, (index) => IncomeSubCategory.fromMap(maps[index]));
  }

  Future<ProfileModel?> getProfileData(String email) async {
    Database db = await database;
    final map = await db.rawQuery(
        "SELECT * FROM $profile_table WHERE ${ProfileTableFields.email} = ?",
        [email]);

    if (map.isNotEmpty) {
      return ProfileModel.fromJson(map.first);
    } else {
      return null;
    }
    /* final reference = FirebaseDatabase.instance
        .reference()
        .child(profile_table)
        .orderByChild(ProfileTableFields.email)
        .equalTo(email);

    Completer<ProfileModel?> completer = Completer<ProfileModel?>();

    reference.once().then((event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
        dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) async {
          ProfileModel?  profileModel = ProfileModel.fromMap(value);
          completer.complete(profileModel);
        });
      }else{
        completer.complete(null);
      }
      });
return completer.future;*/
  }

  // A method that retrieves Profile Data from the Profile table.
  Future<List<ProfileModel>> getProfileDataList() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(profile_table);
    return List.generate(
        maps.length, (index) => ProfileModel.fromMap(maps[index]));
  }

  Future<ProfileModel?> getProfileDataUserCode(String userCode) async {
    /*Database db = await database;
    final map = await db.rawQuery(
        "SELECT * FROM $profile_table WHERE ${ProfileTableFields.user_code} = ?",
        [userCode]);

    if (map.isNotEmpty) {
      return ProfileModel.fromJson(map.first);
    } else {
      return null;
    }*/
    final reference = FirebaseDatabase.instance
        .reference()
        .child(profile_table)
        .orderByChild(ProfileTableFields.user_code)
        .equalTo(userCode);

    Completer<ProfileModel?> completer = Completer<ProfileModel?>();
    ProfileModel? profileModel;
    reference.once().then((event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) async {
          profileModel = ProfileModel.fromMap(value);
          completer.complete(profileModel);
        });
      } else {
        completer.complete(null);
      }
    }).catchError((error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  /// A method that retrieves all the spending sub category from the spending sub table.
  Future<List<ExpenseSubCategory>> getSpendingSubCategory(
      int categoryId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      spending_sub_category_table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(
        maps.length, (index) => ExpenseSubCategory.fromMap(maps[index]));
  }

  /// A method that retrieves all the TransactionData from the TransactionData table.
  Future<List<TransactionModel>> getTransactionData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(transaction_table);
    return List.generate(
        maps.length, (index) => TransactionModel.fromMap(maps[index]));
  }

  Future<List<TransactionModel>> getTransactionList(String category,
      String email, String key, int transactionType, bool isSkippedUser) async {
    if (isSkippedUser) {
      Database db = await database;

      String query = '''SELECT * FROM $transaction_table WHERE ''';
      List<dynamic> whereArgs = [];

      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      query += '(SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?) '
          'AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? '
          'AND ${TransactionFields.member_email} = ? ';

      whereArgs = [
        (currentMonth.toString().padLeft(2, '0')),
        (currentYear.toString()),
        email
      ];

      if (transactionType == -1) {
        if (category.isNotEmpty) {
          query += 'AND (${TransactionFields.cat_name} LIKE ? COLLATE NOCASE '
              'OR ${TransactionFields.description} LIKE ? COLLATE NOCASE) ';
          whereArgs.add('%$category%');
          whereArgs.add('%$category%');
        }
      } else {
        if (category.isNotEmpty) {
          query += 'AND ${TransactionFields.transaction_type} = ? '
              'AND (${TransactionFields.cat_name} LIKE ? COLLATE NOCASE '
              'OR ${TransactionFields.description} LIKE ? COLLATE NOCASE) ';
          whereArgs.add(transactionType);
          whereArgs.add('%$category%');
          whereArgs.add('%$category%');
        } else {
          query += 'AND ${TransactionFields.transaction_type} = ?';
          whereArgs.add(transactionType);
        }
      }
      query += ' ORDER BY ${TransactionFields.transaction_date} DESC';
      print('object.  query...${query}');
      print('object.  Arguments...${whereArgs}');
      List<Map<String, dynamic>> result = await db.rawQuery(
        query,
        whereArgs,
      );

      return List.generate(
          result.length, (index) => TransactionModel.fromMap(result[index]));
    } else {
      Completer<List<TransactionModel>> completer =
          Completer<List<TransactionModel>>();
      List<TransactionModel> transactions = [];
      final reference = await FirebaseDatabase.instance
          .reference()
          .child(transaction_table)
          .child(key)
          .orderByChild(TransactionFields.member_email)
          .equalTo(email);

      reference.once().then((value) {
        DataSnapshot dataSnapshot = value.snapshot;
        if (value.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            if ((category.isEmpty ||
                value[TransactionFields.cat_name]
                    .toLowerCase()
                    .contains(category.toLowerCase()) ||
                value[TransactionFields.description]
                    .toLowerCase()
                    .contains(category.toLowerCase()))) {
              if (transactionType != -1) {
                if (value[TransactionFields.transaction_type] ==
                    transactionType) {
                  transactions.add(TransactionModel.fromMap(value));
                }
              } else {
                transactions.add(TransactionModel.fromMap(value));
              }
            }
          });
          // Sort transactions by transaction date in descending order
          transactions.sort(
              (a, b) => b.transaction_date!.compareTo(a.transaction_date!));
        }
        completer.complete(transactions);
      }).catchError((error) {
        completer.completeError(error);
      });

      return completer.future;
    }
  }

  Future<List<TransactionModel>> getTransactions(int transactionType) async {
    Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(transaction_table,
        where: '${TransactionFields.transaction_type} = ?',
        whereArgs: [transactionType],
        orderBy: '${TransactionFields.created_at} DESC');
    return List.generate(
        maps.length, (index) => TransactionModel.fromMap(maps[index]));
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}em.db';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  Future<int> insertAllCategory(List<ExpenseCategory> categories) async {
    final db = await database;

    final Batch batch = db.batch();

    for (ExpenseCategory category in categories) {
      batch.insert(expense_category_table, category.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  Future<int> insertAllCurrencyMethods(
      List<CurrencyCategory> currencyCategory) async {
    final db = await database;
    final Batch batch = db.batch();
    for (CurrencyCategory currencyCategory in currencyCategory) {
      batch.insert(currency_table, currencyCategory.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  Future<int> insertAllLanguageMethods(
      List<LanguageCategory> languageCategory) async {
    final db = await database;

    final Batch batch = db.batch();

    for (LanguageCategory languageCategory in languageCategory) {
      batch.insert(language_table, languageCategory.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  Future<int> insertAllPaymentMethods(
      List<PaymentMethod> paymentMethods) async {
    final db = await database;

    final Batch batch = db.batch();

    for (PaymentMethod paymentMethod in paymentMethods) {
      batch.insert(payment_method_table, paymentMethod.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  Future<int> insertAllSpendingSubCategory(
      List<ExpenseSubCategory> categories) async {
    final db = await database;

    final Batch batch = db.batch();

    for (ExpenseSubCategory category in categories) {
      batch.insert(spending_sub_category_table, category.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  Future<void> insertCategory(ExpenseCategory category) async {
    Database db = await database;

    await db.insert(expense_category_table, category.toMap());
  }

  Future<void> insertCurrencyMethod(CurrencyCategory currencyCategory) async {
    Database db = await database;
    await db.insert(currency_table, currencyCategory.toMap());
  }

  Future<int> insertIncomeAllCategory(List<IncomeCategory> categories) async {
    final db = await database;

    final Batch batch = db.batch();

    for (IncomeCategory category in categories) {
      batch.insert(income_category_table, category.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  // Insert Income Category
  Future<void> insertIncomeCategory(IncomeCategory incomeCategory) async {
    Database db = await database;
    await db.insert(income_category_table, incomeCategory.toMap());
  }

  /// Insert Income Sub Category
  Future<void> insertIncomeSubCategory(
      int categoryId, IncomeSubCategory incomeSubCategory) async {
    incomeSubCategory.categoryId = categoryId;
    Database db = await database;
    await db.insert(income_sub_category_table, incomeSubCategory.toMap());
  }

  Future<void> insertLanguageMethod(LanguageCategory languageCategory) async {
    Database db = await database;
    await db.insert(language_table, languageCategory.toMap());
  }

  /// Insert Payment Method
  Future<void> insertPaymentMethod(PaymentMethod paymentMethod) async {
    Database db = await database;
    await db.insert(payment_method_table, paymentMethod.toMap());
  }

  // Insert ProfileData
  Future<void> insertProfileData(
      ProfileModel profileModel, bool isProfileExistInFirebaseDb) async {
    Database db = await database;

    if (!isProfileExistInFirebaseDb) {
      FirebaseDatabase.instance
          .reference()
          .child(profile_table)
          .child(FirebaseAuth.instance.currentUser!.uid)
          .set(
            profileModel.toMap(),
          );
    }

    await db.insert(profile_table, profileModel.toMap());
  }

  /// Insert Spending Sub Category
  Future<void> insertSpendingSubCategory(
      int categoryId, ExpenseSubCategory spendingSubCategory) async {
    spendingSubCategory.categoryId = categoryId;
    Database db = await database;
    await db.insert(spending_sub_category_table, spendingSubCategory.toMap());
  }

  /// Insert Transaction Detail
  Future<int> insertTransactionData(
      TransactionModel transactionModel,String key, bool isSkippedUser) async {
    Database db = await database;
    if (!isSkippedUser) {
      final reference = FirebaseDatabase.instance
          .reference()
          .child(transaction_table)
          .child(key);
      var newPostRef = reference.push();
      transactionModel.key = newPostRef.key;
      newPostRef.set(
        transactionModel.toMap(),
      );

    }
    else{
      final reference = FirebaseDatabase.instance
          .reference()
          .child(transaction_table);
      var newPostRef = reference.push();
      transactionModel.key = newPostRef.key;
    }
    return await db.insert(transaction_table, transactionModel.toMap());
  }

  Future<void> insertMultipleTransactions(

      List<TransactionModel> transactions,String key, bool isSkippedUser) async {
    Database db = await database;
    Batch batch = db.batch();

    for (var transaction in transactions) {
      transaction.key = key;
      if (!isSkippedUser) {
        final reference = FirebaseDatabase.instance
            .reference()
            .child(transaction_table)
            .child(key);
        var newPostRef = reference.push();
        transaction.key = newPostRef.key;
        await newPostRef.set(
          transaction.toMap(),
        );
      }
      else {
        final reference =
        FirebaseDatabase.instance.reference().child(transaction_table);
        var newPostRef = reference.push();
        transaction.key = newPostRef.key;
      }
      batch.insert(transaction_table, transaction.toMap());
    }

    await batch.commit(noResult: true);
  }

  /// A method that retrieves all the language methods from the paymentMethods table.
  Future<List<LanguageCategory>> languageMethods() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(language_table);
    return List.generate(
        maps.length, (index) => LanguageCategory.fromMap(maps[index]));
  }

  /// A method that retrieves all the paymentMethods from the paymentMethods table.
  Future<List<PaymentMethod>> paymentMethods() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(payment_method_table);
    return List.generate(
        maps.length, (index) => PaymentMethod.fromMap(maps[index]));
  }

  Future<void> updateCurrencyMethod(CurrencyCategory currencyCategory) async {
    final db = await database;
    await db.update(currency_table, currencyCategory.toMap(),
        where: '${CurrencyFields.id} = ?', whereArgs: [currencyCategory.id]);
  }

  /// Update Income Category
  Future<void> updateIncomeCategory(IncomeCategory incomeCategory) async {
    var db = await database;
    await db.update(income_category_table, incomeCategory.toMap(),
        where: '${CategoryFields.id} = ?', whereArgs: [incomeCategory.id]);
  }

  /// Update Income Sub Category
  Future<void> updateIncomeSubCategory(
      IncomeSubCategory incomeSubCategory) async {
    var db = await database;
    await db.update(income_sub_category_table, incomeSubCategory.toMap(),
        where: '${IncomeSubCategoryFields.id} = ?',
        whereArgs: [incomeSubCategory.id]);
  }

  Future<void> updateLanguageMethod(LanguageCategory languageCategory) async {
    final db = await database;
    await db.update(language_table, languageCategory.toMap(),
        where: '${LanguageFields.id} = ?', whereArgs: [languageCategory.id]);
  }

  /// Update Payment Method
  Future<void> updatePaymentMethod(PaymentMethod paymentMethod) async {
    final db = await database;
    await db.update(payment_method_table, paymentMethod.toMap(),
        where: '${PaymentMethodFields.id} = ?', whereArgs: [paymentMethod.id]);
  }

  // Update ProfileData
  Future<void> updateProfileData(ProfileModel profileModel) async {
    try {
      final db = await database;
      await db.update(profile_table, profileModel.toMap(),
          where: '${ProfileTableFields.email} = ?',
          whereArgs: [profileModel.email]);
    }catch(e){
      e.printError();
    }
    final Map<String, Map> updates = {};
    updates['/$profile_table/${profileModel.key}'] = profileModel.toMap();
    FirebaseDatabase.instance.ref().update(updates);
  }

/// Update Spending Sub Category
  Future<void> updateSpendingSubCategory(
      ExpenseSubCategory spendingSubCategory) async {
    var db = await database;
    await db.update(spending_sub_category_table, spendingSubCategory.toMap(),
        where: '${ExpenseSubCategoryFields.id} = ?',
        whereArgs: [spendingSubCategory.id]);
  }

  Future<void> updateTransaction(TransactionModel transactionModel) async {
    final db = await database;
    await db.update(transaction_table, transactionModel.toMap(),
        where: '${TransactionFields.key} = ?',
        whereArgs: [transactionModel.key]);
  }

  Future<int> updateTransactionData(
      TransactionModel transactionModel, String key,bool isSkippedUser) async {
    Database db = await database;
    if (!isSkippedUser) {
      final Map<String, Map> updates = {};
      updates['/$transaction_table/$key/${transactionModel.key}'] =
          transactionModel.toMap();
      FirebaseDatabase.instance.ref().update(updates);
    }

    return await db.update(transaction_table, transactionModel.toMap(),
        where: '${TransactionFields.key} = ?',
        whereArgs: [transactionModel.key]);
  }

  void _createDb(Database db, int newVersion) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const keyType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $transaction_table (
      ${TransactionFields.key} $keyType,
      ${TransactionFields.member_email} $textType,
      ${TransactionFields.amount} $integerType,
      ${TransactionFields.expense_cat_id} $integerType,
      ${TransactionFields.income_cat_id} $integerType,
      ${TransactionFields.sub_expense_cat_id} $integerType,
      ${TransactionFields.sub_income_cat_id} $integerType,
      ${TransactionFields.cat_name} $textType,
      ${TransactionFields.cat_type} $integerType,
      ${TransactionFields.cat_icon} $textType,
      ${TransactionFields.cat_color} $integerType,
      ${TransactionFields.payment_method_id} $integerType,
      ${TransactionFields.payment_method_name} $textType,
      ${TransactionFields.status} $integerType,
      ${TransactionFields.transaction_date} $integerType,
      ${TransactionFields.transaction_type} $integerType,
      ${TransactionFields.description} $textType,
      ${TransactionFields.currency_id} $integerType,
      ${TransactionFields.receipt_image1} $textType,
      ${TransactionFields.receipt_image2} $textType,
      ${TransactionFields.receipt_image3} $textType,
      ${TransactionFields.created_at} $textType,
      ${TransactionFields.last_updated} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $payment_method_table (
      ${PaymentMethodFields.id} $idType,
      ${PaymentMethodFields.name} $textType,
      ${PaymentMethodFields.status} $integerType,
      ${PaymentMethodFields.icon} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $income_category_table (
      ${CategoryFields.id} $idType,
      ${CategoryFields.name} $textType,
      ${CategoryFields.parent_id} $integerType,
      ${CategoryFields.path} $textType,
      ${CategoryFields.status} $integerType,
      ${CategoryFields.color} $integerType
      )
   ''');

    await db.execute('''
      CREATE TABLE $expense_category_table(
      ${ExpenseCategoryField.id} $idType,
      ${ExpenseCategoryField.name} $textType,
      ${ExpenseCategoryField.color} $integerType,
      ${ExpenseCategoryField.icons} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $spending_sub_category_table(
      ${ExpenseSubCategoryFields.id} $idType,
      ${ExpenseSubCategoryFields.name} $textType,
      ${ExpenseSubCategoryFields.categoryId} $integerType,
      ${ExpenseSubCategoryFields.priority} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $currency_table(
      ${CurrencyFields.id} $idType,
      ${CurrencyFields.countryName} $textType,
      ${CurrencyFields.symbol} $textType,
      ${CurrencyFields.currencyCode} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $language_table(
      ${LanguageFields.id} $idType,
      ${LanguageFields.name} $textType,
      ${LanguageFields.code} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $income_sub_category_table(
      ${IncomeSubCategoryFields.id} $idType,
      ${IncomeSubCategoryFields.name} $textType,
      ${IncomeSubCategoryFields.categoryId} $integerType,
      ${IncomeSubCategoryFields.priority} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $accounts_table(
      ${AccountTableFields.account_id} $idType,
      ${AccountTableFields.key} $textType,
      ${AccountTableFields.owner_user_id} $integerType,
      ${AccountTableFields.account_name} $textType,
      ${AccountTableFields.description} $textType,
      ${AccountTableFields.budget} $textType,
      ${AccountTableFields.balance} $textType,
      ${AccountTableFields.balance_date} $textType,
      ${AccountTableFields.account_status} $textType,
      ${AccountTableFields.created_at} $textType,
      ${AccountTableFields.updated_at} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $profile_table(
      ${ProfileTableFields.key} $keyType,
      ${ProfileTableFields.first_name} $textType,
      ${ProfileTableFields.last_name} $textType,
      ${ProfileTableFields.email} $textType,
      ${ProfileTableFields.full_name} $textType,
      ${ProfileTableFields.user_code} $textType,
      ${ProfileTableFields.dob} $textType,
      ${ProfileTableFields.profile_image} $textType,
      ${ProfileTableFields.mobile_number} $textType,
      ${ProfileTableFields.current_balance} $textType,
      ${ProfileTableFields.current_income} $textType,
      ${ProfileTableFields.actual_budget} $textType,
      ${ProfileTableFields.gender} $textType,
      ${ProfileTableFields.fcm_token} $textType,
      ${ProfileTableFields.lang_code} $textType,
      ${ProfileTableFields.currency_code} $textType,
      ${ProfileTableFields.currency_symbol} $textType
      )
   ''');
  }

  static Future<String> exportAllToCSV(String userEmail) async {
    String csv = "";

    final firebaseTask = await getFirebaseTasks(userEmail);
    Map<String, List<TransactionModel>> accountData = {};
    for (var task in firebaseTask) {
      accountData.putIfAbsent(task.member_email!, () => []).add(task);
    }

    for (var entry in accountData.entries) {
      List<List<dynamic>> rows = [
        [
          'member_email',
          'amount',
          'cat_name',
          'cat_type',
          'payment_method_name',
          'transaction_date',
          'transaction_type',
          'description',
          'receipt_image1',
          'receipt_image2',
          'receipt_image3',
          'transaction_key'
        ]
      ];

      /// Add transaction data
      for (var task in entry.value) {
        rows.add([
          task.member_email,
          task.amount,
          task.cat_name,
          task.cat_type,
          task.payment_method_name,
          task.transaction_date,
          task.transaction_type,
          task.description ?? "",
          task.receipt_image1 ?? "",
          task.receipt_image2 ?? "",
          task.receipt_image2 ?? "",
          task.key ?? ""
        ]);
      }
      csv = const ListToCsvConverter().convert(rows);
    }
    return csv;
  }

  static Future<MultipleEmailModel> exportAccessEmailDataToCSV(String userEmail) async {
    MultipleEmailModel multipleEmailModel = MultipleEmailModel();
    List<String> receiversName = [];
    List<ReceiverEmailData> receiverEmailList = await getAccessEmails(userEmail);
    for (var entry in receiverEmailList) {
      String recName = entry.receiverName.toString();
      receiversName.add(recName);
      List<List<dynamic>> rows = [
        [
          'member_email',
          'amount',
          'cat_name',
          'cat_type',
          'payment_method_name',
          'transaction_date',
          'transaction_type',
          'description',
          'receipt_image1',
          'receipt_image2',
          'receipt_image3',
          'transaction_key'
        ]
      ];

      /// Add transaction data
      for (var task in entry.transactionModel! ) {
        rows.add([
          task.member_email,
          task.amount,
          task.cat_name,
          task.cat_type,
          task.payment_method_name,
          task.transaction_date,
          task.transaction_type,
          task.description ?? "",
          task.receipt_image1 ?? "",
          task.receipt_image2 ?? "",
          task.receipt_image2 ?? "",
          task.key ?? ""
        ]);
      }
      String csvContent = const ListToCsvConverter().convert(rows);
      multipleEmailModel.csv[recName] = csvContent;
    }
    multipleEmailModel.receiversName = receiversName;
    return multipleEmailModel;
  }


  static Future<List<ReceiverEmailData>> getAccessEmails(String userEmail) async {
    Completer<List<ReceiverEmailData>> completer = Completer<List<ReceiverEmailData>>();
    List<ReceiverEmailData> receiverEmailList = [];
    final accessReference = FirebaseDatabase.instance
        .reference()
        .child(request_table)
        .orderByChild('requester_email')
        .equalTo(userEmail);

    accessReference.once().then((event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;

        List<Future<void>> futures = [];

        values.forEach((key, value) {
          var future = FirebaseDatabase.instance
              .reference()
              .child(profile_table)
              .orderByChild(ProfileTableFields.email)
              .equalTo(value['receiver_email'])
              .once()
              .then((event) async {
            DataSnapshot dataSnapshot = event.snapshot;
            if (event.snapshot.exists) {
              Map<dynamic, dynamic> profileValues = dataSnapshot.value as Map<dynamic, dynamic>;

              List<Future<void>> innerFutures = [];
              profileValues.forEach((profileKey, profileValue) {
                innerFutures.add(FirebaseDatabase.instance
                    .reference()
                    .child(transaction_table)
                    .child(profileKey)
                    .orderByChild(TransactionFields.member_email)
                    .equalTo(value['receiver_email'])
                    .once()
                    .then((transactionEvent) {
                  List<TransactionModel> transactionsEmail = [];
                  DataSnapshot transactionSnapshot = transactionEvent.snapshot;
                  if (transactionSnapshot.value != null) {
                    Map<dynamic, dynamic> taskValues = transactionSnapshot.value as Map<dynamic, dynamic>;
                    taskValues.forEach((taskKey, taskValue) {
                      transactionsEmail.add(TransactionModel.fromMapForCSV(taskValue));
                    });
                  }

                  receiverEmailList.add(ReceiverEmailData(
                    receiverEmail: value['receiver_email'],
                    transactionModel: transactionsEmail,
                    receiverName: value['receiver_name'],
                  ));
                }));
              });

              await Future.wait(innerFutures);
            }
          });

          futures.add(future);
        });

        await Future.wait(futures);
        completer.complete(receiverEmailList);
      } else {
        completer.complete(receiverEmailList);
      }
    });

    return completer.future;
  }


  static Future<List<TransactionModel>> getFirebaseTasks(String userEmail) async {
    Completer<List<TransactionModel>> completer =Completer<List<TransactionModel>>();
    List<TransactionModel> transactions = [];
    final reference = FirebaseDatabase.instance
        .reference()
        .child(transaction_table)
        .child(FirebaseAuth.instance.currentUser!.uid)
        .orderByChild(TransactionFields.member_email)
        .equalTo(userEmail);
    reference.once().then((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      final tasks = dataSnapshot.value as Map<dynamic, dynamic>;
      tasks.forEach((key, value) async {
        transactions.add(TransactionModel.fromMapForCSV(value));
      });
      completer.complete(transactions);
    });
    return completer.future;
  }
  static Future<List<TransactionModel>> getTransactionsForEmail(String email) async {
    Completer<List<TransactionModel>> completer = Completer<List<TransactionModel>>();
    List<TransactionModel> transactions = [];
    final reference = FirebaseDatabase.instance
        .ref()
        .child(transaction_table)
        .orderByChild(TransactionFields.member_email)
        .equalTo(email);

    reference.once().then((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic>? values = event.snapshot.value as Map<dynamic, dynamic>?;
        if (values != null) {
          values.forEach((key, value) {
            transactions.add(TransactionModel.fromMap(value));
          });
        }
      }
      completer.complete(transactions);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}

// Future<int?> getCategoryColor(/*dynamic categoryId, */String categoryName, int categoryType, int transactionType) async {
//   String tableName = "";
//   String fetchingColor = "";
//   String fetchingName = "";
//
//   if (transactionType == AppConstanst.incomeTransaction) {
//     if (categoryType == 0) {
//       tableName = income_category_table;
//       fetchingColor = CategoryFields.color;
//       fetchingName = CategoryFields.name;
//     }
//     /*else{
//       tableName = spending_sub_category_table;
//       fetchingIcon = ExpenseCategoryField.icons;
//       fetchingName = ExpenseSubCategoryFields.name;
//     }
//   }*/ /*else {
//     if (categoryType == 0) {
//       tableName = income_category_table;
//       fetchingIcon = CategoryFields.path;
//       fetchingName = CategoryFields.name;
//     }
//   }*/
//
//     List<Map<String, dynamic>> result;
//
//     /* if (categoryId != null) {
//     result = await _database!.query(
//       tableName,
//       columns: [fetchingIcon],
//       where: '${ExpenseCategoryField.id} = ?',
//       whereArgs: [categoryId],
//     );
//   } else {*/
//     result = await _database!.query(
//       tableName,
//       columns: [fetchingColor],
//       where: '$fetchingName = ?',
//       whereArgs: [categoryName],
//     );
//     // }
//
//     if (result.isNotEmpty) {
//       return result.first[fetchingColor];
//     } else {
//       return null; // Return null if category icon is not found
//     }
//   }
// }
