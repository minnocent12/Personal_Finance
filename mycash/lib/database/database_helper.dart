import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(path, version: 3, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    // Create the users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Create the income table with date and source columns
    await db.execute('''
      CREATE TABLE income (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        amount REAL,
        description TEXT,
        date TEXT,
        source TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    // Create the expense table with category and date columns
    await db.execute('''
      CREATE TABLE expense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        amount REAL,
        description TEXT,
        category TEXT,
        date TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    // Create the savings goals table with goal_name, target_amount, and target_date columns
    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        goal_name TEXT,
        target_amount REAL,
        target_date TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    // Create the investments table with investment_type, current_value, and purchase_date columns
    await db.execute('''
      CREATE TABLE investments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        investment_type TEXT,
        current_value REAL,
        purchase_date TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');
  }

  // Methods to insert and retrieve data for income, expense, savings, and investments
  Future<int> addIncome(int userId, double amount, String description,
      String date, String source) async {
    final db = await database;
    return await db.insert('income', {
      'user_id': userId,
      'amount': amount,
      'description': description,
      'date': date,
      'source': source
    });
  }

  Future<int> addExpense(int userId, double amount, String description,
      String category, String date) async {
    final db = await database;
    return await db.insert('expense', {
      'user_id': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date
    });
  }

  Future<int> addSavingsGoal(int userId, String goalName, double targetAmount,
      String targetDate) async {
    final db = await database;
    return await db.insert('savings_goals', {
      'user_id': userId,
      'goal_name': goalName,
      'target_amount': targetAmount,
      'target_date': targetDate
    });
  }

  Future<int> addInvestment(int userId, String investmentType,
      double currentValue, String purchaseDate) async {
    final db = await database;
    return await db.insert('investments', {
      'user_id': userId,
      'investment_type': investmentType,
      'current_value': currentValue,
      'purchase_date': purchaseDate
    });
  }

  Future<double> getTotalIncome(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM income WHERE user_id = ?', [userId]);
    return result.isNotEmpty && result[0]['total'] != null
        ? (result[0]['total'] as double)
        : 0.0;
  }

  Future<double> getTotalExpenses(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expense WHERE user_id = ?', [userId]);
    return result.isNotEmpty && result[0]['total'] != null
        ? (result[0]['total'] as double)
        : 0.0;
  }

  Future<double> getTotalSavings(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(target_amount) as total FROM savings_goals WHERE user_id = ?',
        [userId]);
    return result.isNotEmpty && result[0]['total'] != null
        ? (result[0]['total'] as double)
        : 0.0;
  }

  Future<double> getTotalInvestments(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(current_value) as total FROM investments WHERE user_id = ?',
        [userId]);
    return result.isNotEmpty && result[0]['total'] != null
        ? (result[0]['total'] as double)
        : 0.0;
  }

  Future<int> createUser(
      String firstName, String lastName, String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password
    });
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    var result = await db.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);

    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    var result =
        await db.query('users', where: 'email = ?', whereArgs: [email]);

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final db = await database;
    return await db.update('users', {'password': newPassword},
        where: 'email = ?', whereArgs: [email]);
  }

  Future<bool> isEmailUsed(String email) async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM users WHERE email = ?", [email]);
    return res.isNotEmpty;
  }

  Future<void> updateIncome(int id, double amount, String description,
      String date, String source) async {
    final db = await database;
    await db.update(
      'income',
      {
        'amount': amount,
        'description': description,
        'date': date,
        'source': source,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeByUserId(int userId) async {
    final db = await database;
    return await db.query('income', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Method to retrieve expenses for a specific user
  Future<List<Map<String, dynamic>>> getExpenses(int userId) async {
    final db = await database;
    return await db
        .query('expenses', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Method to retrieve savings goals for a specific user
  Future<List<Map<String, dynamic>>> getSavingsGoals(int userId) async {
    final db = await database;
    return await db
        .query('savings_goals', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Method to retrieve investments for a specific user
  Future<List<Map<String, dynamic>>> getInvestments(int userId) async {
    final db = await database;
    return await db
        .query('investments', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> deleteIncome(int id) async {
    final db = await database;
    await db.delete('income', where: 'id = ?', whereArgs: [id]);
  }
}
