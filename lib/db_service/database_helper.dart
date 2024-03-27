import 'dart:async';
import 'dart:io';

import 'package:expense_manager/db_models/transaction_model.dart';
import 'package:expense_manager/db_models/user_model.dart';
import 'package:expense_manager/statistics/statistics_screen.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../db_models/category_model.dart';
import '../db_models/expence_category.dart';
import '../db_models/income_category.dart';
import '../db_models/income_sub_category.dart';
import '../db_models/payment_method_model.dart';
import '../db_models/profile_model.dart';
import '../db_models/spending_sub_category.dart';
import '../utils/global.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper.init();

  DatabaseHelper.init();

  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}em.db';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $user_table (
      ${UserTableFields.id} $idType, 
      ${UserTableFields.username} $integerType,
      ${UserTableFields.full_name} $integerType,
      ${UserTableFields.password} $textType,
      ${UserTableFields.email} $integerType,
      ${UserTableFields.current_balance} $integerType,
      ${UserTableFields.profile_image} $textType,
      ${UserTableFields.created_at} $textType,
      ${UserTableFields.last_updated} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $transaction_table (
      ${TransactionFields.id} $idType,
      ${TransactionFields.member_id} $integerType,
      ${TransactionFields.member_email} $textType,
      ${TransactionFields.amount} $integerType,
      ${TransactionFields.expense_cat_id} $integerType,
      ${TransactionFields.income_cat_id} $integerType,
      ${TransactionFields.sub_expense_cat_id} $integerType,
      ${TransactionFields.sub_income_cat_id} $integerType,
      ${TransactionFields.cat_name} $textType,
      ${TransactionFields.cat_icon} $textType,
      ${TransactionFields.cat_color} $integerType,
      ${TransactionFields.payment_method_id} $integerType,
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
      ${PaymentMethodFields.status} $integerType
      )
   ''');

    await db.execute('''
      CREATE TABLE $income_category_table (
      ${CategoryFields.id} $idType,
      ${CategoryFields.name} $textType,
      ${CategoryFields.parent_id} $integerType,
      ${CategoryFields.path} $textType,
      ${CategoryFields.status} $integerType,
      ${CategoryField.color} $integerType
      )
   ''');

    await db.execute('''
      CREATE TABLE $expence_category_table(
      ${ExpenceCategoryFields.id} $idType,
      ${ExpenceCategoryFields.name} $textType,
      ${ExpenceCategoryFields.parent_id} $integerType,
      ${ExpenceCategoryFields.path} $textType,
      ${ExpenceCategoryFields.status} $integerType
      )
   ''');

    await db.execute('''
      CREATE TABLE $category_table(
      ${CategoryField.id} $idType,
      ${CategoryField.name} $textType,
      ${CategoryField.color} $integerType,
      ${CategoryField.icons} $textType
      )
   ''');

    await db.execute('''
      CREATE TABLE $spending_sub_category_table(
      ${SpendingSubCategoryFields.id} $idType,
      ${SpendingSubCategoryFields.name} $textType,
      ${SpendingSubCategoryFields.categoryId} $integerType,
      ${SpendingSubCategoryFields.priority} $textType
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
      CREATE TABLE $profile_table(
      ${ProfileTableFields.id} $idType,
      ${ProfileTableFields.first_name} $textType,
      ${ProfileTableFields.last_name} $textType,
      ${ProfileTableFields.email} $textType,
      ${ProfileTableFields.full_name} $textType,
      ${ProfileTableFields.dob} $textType,
      ${ProfileTableFields.profile_image} $textType,
      ${ProfileTableFields.mobile_number} $textType,
      ${ProfileTableFields.current_balance} $textType,
      ${ProfileTableFields.current_income} $textType,
      ${ProfileTableFields.actual_budget} $textType,
      ${ProfileTableFields.gender} $textType
      )
   ''');
  }

  // Insert ProfileData
  Future<void> insertProfileData(ProfileModel profileModel) async {
    Database db = await database;

    await db.insert(profile_table, profileModel.toMap());
  }

  // Update ProfileData
  Future<void> updateProfileData(ProfileModel profileModel) async {
    final db = await database;
    await db.update(profile_table, profileModel.toMap(),
        where: '${ProfileTableFields.email} = ?',
        whereArgs: [profileModel.email]);
  }


  // A method that retrieves Profile Data from the Profile table.
  Future<List<ProfileModel>> getProfileDataList() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(profile_table);
    return List.generate(
        maps.length, (index) => ProfileModel.fromMap(maps[index]));
  }

  Future<ProfileModel> getProfileData(String email) async {
    Database db = await database;
    final map = await db.rawQuery(
        "SELECT * FROM $profile_table WHERE ${ProfileTableFields.email} = ?",
        [email]);

    if (map.isNotEmpty) {
      return ProfileModel.fromJson(map.first);
    } else {
      throw Exception("User: $email not found");
    }
  }

  // Insert UserData
  Future<int> insertUserData(UserModel userModel) async {
    Database db = await database;
    var result = await db.insert(user_table, userModel.toMap());
    return result;
  }

  // Update UserData
  Future<int> updateUserData(UserModel userModel) async {
    var db = await database;
    var result = await db.update(user_table, userModel.toMap(),
        where: '${UserTableFields.id} = ?', whereArgs: [userModel.id]);
    return result;
  }

  Future<void> insertCategory(Category category) async {
    Database db = await database;

    await db.insert(category_table, category.toMap());
  }

  Future<int> insertAllCategory(List<Category> categories) async {
    final db = await database;

    final Batch batch = db.batch();

    for (Category category in categories) {
      batch.insert(category_table, category.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  // A method that retrieves all the category from the category table.
  Future<List<Category>> categorys() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(category_table);
    return List.generate(maps.length, (index) => Category.fromMap(maps[index]));
  }

  // Insert Payment Method
  Future<void> insertPaymentMethod(PaymentMethod paymentMethod) async {
    Database db = await database;
    await db.insert(payment_method_table, paymentMethod.toMap());
  }

  // A method that retrieves all the paymentMethods from the paymentMethods table.
  Future<List<PaymentMethod>> paymentMethods() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(payment_method_table);
    return List.generate(
        maps.length, (index) => PaymentMethod.fromMap(maps[index]));
  }

  // Update Payment Method
  Future<void> updatePaymentMethod(PaymentMethod paymentMethod) async {
    final db = await database;
    await db.update(payment_method_table, paymentMethod.toMap(),
        where: '${PaymentMethodFields.id} = ?', whereArgs: [paymentMethod.id]);
  }

  // Insert Income Category
  Future<void> insertIncomeCategory(IncomeCategory incomeCategory) async {
    Database db = await database;
    await db.insert(income_category_table, incomeCategory.toMap());
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

  // A method that retrieves all the IncomeCategory from the IncomeCategory table.
  Future<List<IncomeCategory>> getIncomeCategory() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(income_category_table);
    return List.generate(
        maps.length, (index) => IncomeCategory.fromMap(maps[index]));
  }

  // Update Income Category
  Future<void> updateIncomeCategory(IncomeCategory incomeCategory) async {
    var db = await database;
    await db.update(income_category_table, incomeCategory.toMap(),
        where: '${CategoryFields.id} = ?', whereArgs: [incomeCategory.id]);
  }

  // Insert Expense Category
  Future<void> insertExpenseCategory(ExpenseCategory expenseCategory) async {
    Database db = await database;
    await db.insert(expence_category_table, expenseCategory.toMap());
  }

  // A method that retrieves all the ExpenseCategory from the ExpenseCategory table.
  Future<List<ExpenseCategory>> getExpenseCategory() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(expence_category_table);
    return List.generate(
        maps.length, (index) => ExpenseCategory.fromMap(maps[index]));
  }

  // Update Expense Category
  Future<void> updateExpenseCategory(ExpenseCategory expenseCategory) async {
    var db = await database;
    await db.update(expence_category_table, expenseCategory.toMap(),
        where: '${ExpenceCategoryFields.id} = ?',
        whereArgs: [expenseCategory.id]);
  }

  // Insert Transaction Detail
  Future<int> insertTransactionData(TransactionModel transactionModel) async {
    Database db = await database;
    return await db.insert(transaction_table, transactionModel.toMap());
  }

  // A method that retrieves all the TransactionData from the TransactionData table.
  Future<List<TransactionModel>> getTransactionData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(transaction_table);
    return List.generate(
        maps.length, (index) => TransactionModel.fromMap(maps[index]));
  }

  Future<void> updateTransaction(TransactionModel transactionModel) async {
    final db = await database;
    await db.update(transaction_table, transactionModel.toMap(),
        where: '${TransactionFields.id} = ?',
        whereArgs: [transactionModel.id]);
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

  //Get transaction data for current month
  Future<List<TransactionModel>> fetchDataForCurrentMonth(
      int transactionType,String email) async {
    Database db = await database;
    // Get the current month and year
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    final List<Map<String, dynamic>> result = await db.query(
      transaction_table,
      where:
          'SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ? AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ${TransactionFields.transaction_type} = ? AND ${TransactionFields.member_email} = ?',
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
  }


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

  Future<List<TransactionModel>> fetchDataForYearMonthsAndCategory1() async {
    Database db = await database;
    String query = '''SELECT * FROM $transaction_table WHERE ''';

    List<MonthData> months = [];
    months.add(new MonthData(text: 'March'));
    months.add(new MonthData(text: 'February'));

    List<int> selectedMonthNumbers = months
        .map((monthData) => monthNameToNumber[monthData.text])
        .where((monthNumber) => monthNumber != null)
        .map((monthNumber) => monthNumber!)
        .toList();

    List<String> conditions = [];

    for (int month in selectedMonthNumbers) {
      conditions.add('SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?');
    }

    query += conditions.join(' OR '); // Combine conditions using OR operator
    query +=
    '''
  AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? 
  ORDER BY ${TransactionFields.transaction_date} DESC
''';

    // Construct the where clause and where arguments
    /*  String whereClause = "strftime('%Y', transaction_date) = ? AND ";
    whereClause += '(${selectedMonthNumbers
            .map((month) =>
                'SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?')
            .join(' OR ')}) AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ';
    whereClause += "cat_name = ? AND ";
    whereClause += "transaction_type = ?";*/

    List<dynamic> whereArgs = [
      ...selectedMonthNumbers.map((month) => month.toString().padLeft(2, '0')),
    ];

    print('object....$query....${whereArgs.toString()}');
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
  }

  Future<List<TransactionModel>> fetchDataForYearMonthsAndCategory(int year,
      List<MonthData> months, String category, int transactionType) async {
    Database db = await database;
    String query = '''SELECT * FROM $transaction_table WHERE ''';
    /*   List<int?> selectedMonthNumbers =
        months.map((monthData) => monthNameToNumber[monthData.text]).toList();*/

    List<int> selectedMonthNumbers = months
        .map((monthData) => monthNameToNumber[monthData.text])
        .where((monthNumber) => monthNumber != null)
        .map((monthNumber) => monthNumber!)
        .toList();

    List<String> conditions = [];

    for (int month in selectedMonthNumbers) {
      conditions.add('SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?');
    }

    query += conditions.join(' OR '); // Combine conditions using OR operator
    query +=
    '''
  AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? 
   AND ${TransactionFields.transaction_type} = ?
  ORDER BY ${TransactionFields.transaction_date} DESC
''';
    // Construct the where clause and where arguments
    /*  String whereClause = "strftime('%Y', transaction_date) = ? AND ";
    whereClause += '(${selectedMonthNumbers
            .map((month) =>
                'SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ?')
            .join(' OR ')}) AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ';
    whereClause += "cat_name = ? AND ";
    whereClause += "transaction_type = ?";*/

    List<dynamic> whereArgs = [
      ...selectedMonthNumbers.map((month) => month.toString().padLeft(2, '0')),
      year.toString(),
      transactionType
    ];
print('object...$query...${whereArgs}');
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
  }

  Future<List<TransactionModel>> getTransactionList(String category,String email) async {
    Database db = await database;
    // Get the current month and year
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;


    List<Map<String, dynamic>> maps = [];
    if (category.isNotEmpty) {
      maps = await db.query(transaction_table,
          where:
              'SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ? AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ${TransactionFields.cat_name} LIKE ? COLLATE NOCASE OR ${TransactionFields.description} LIKE ? COLLATE NOCASE AND ${TransactionFields.member_email} = ?',
          whereArgs: [
            (currentMonth.toString().padLeft(2, '0')),
            (currentYear.toString()),
            '%$category%', '%$category%',
            email
          ],
          orderBy: '${TransactionFields.created_at} DESC');
    } else {
      maps = await db.query(transaction_table,
          where:
          'SUBSTR(${TransactionFields.transaction_date}, 4, 2) = ? AND SUBSTR(${TransactionFields.transaction_date}, 7, 4) = ? AND ${TransactionFields.member_email} = ?',
          whereArgs: [
            (currentMonth.toString().padLeft(2, '0')),
            (currentYear.toString()),
            email
          ],
          orderBy: '${TransactionFields.created_at} DESC');
    }
    return List.generate(
        maps.length, (index) => TransactionModel.fromMap(maps[index]));
  }

  // Update Transaction Detail
  Future<void> updateTransactionData(TransactionModel transactionModel) async {
    var db = await database;
    await db.update(transaction_table, transactionModel.toMap(),
        where: '${TransactionFields.id} = ?', whereArgs: [transactionModel.id]);
  }

  // Insert Income Sub Category
  Future<void> insertIncomeSubCategory(
      int categoryId, IncomeSubCategory incomeSubCategory) async {
    incomeSubCategory.categoryId = categoryId;
    Database db = await database;
    await db.insert(income_sub_category_table, incomeSubCategory.toMap());
  }

  // Update Income Sub Category
  Future<void> updateIncomeSubCategory(
      IncomeSubCategory incomeSubCategory) async {
    var db = await database;
    await db.update(income_sub_category_table, incomeSubCategory.toMap(),
        where: '${IncomeSubCategoryFields.id} = ?',
        whereArgs: [incomeSubCategory.id]);
  }

  // A method that retrieves all the income sub category from the income sub table.
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

  // Insert Spending Sub Category
  Future<void> insertSpendingSubCategory(
      int categoryId, SpendingSubCategory spendingSubCategory) async {
    spendingSubCategory.categoryId = categoryId;
    Database db = await database;
    await db.insert(spending_sub_category_table, spendingSubCategory.toMap());
  }

  Future<int> insertAllSpendingSubCategory(
      List<SpendingSubCategory> categories) async {
    final db = await database;

    final Batch batch = db.batch();

    for (SpendingSubCategory category in categories) {
      batch.insert(spending_sub_category_table, category.toMap());
    }

    final List<dynamic> result = await batch.commit();
    final int affectedRows = result.reduce((sum, element) => sum + element);
    return affectedRows;
  }

  // Update Spending Sub Category
  Future<void> updateSpendingSubCategory(
      SpendingSubCategory spendingSubCategory) async {
    var db = await database;
    await db.update(spending_sub_category_table, spendingSubCategory.toMap(),
        where: '${SpendingSubCategoryFields.id} = ?',
        whereArgs: [spendingSubCategory.id]);
  }

  // A method that retrieves all the spending sub category from the spending sub table.
  Future<List<SpendingSubCategory>> getSpendingSubCategory(
      int categoryId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      spending_sub_category_table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(
        maps.length, (index) => SpendingSubCategory.fromMap(maps[index]));
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

  Future<void> clearAllTables() async{
    Database db = await instance.database;
    await db.delete(transaction_table);
    await db.delete(profile_table);
    Helper.showToast("All transaction are deleted.");
  }

}
