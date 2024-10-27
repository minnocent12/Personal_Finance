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
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  _onCreate(Database db, int version) async {
    // Create the users table with monthly_budget column
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        monthly_budget REAL DEFAULT 0
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
// savings_goals table
    await db.execute('''
  CREATE TABLE IF NOT EXISTS savings_goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    goal_name TEXT,
    target_amount REAL,
    current_amount REAL DEFAULT 0,
    target_date TEXT,
    FOREIGN KEY(user_id) REFERENCES users(id)
  )
''');

// Create savings_entries table for tracking individual savings
    await db.execute('''
  CREATE TABLE IF NOT EXISTS savings_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal_id INTEGER,
    amount REAL,
    date TEXT,
    FOREIGN KEY(goal_id) REFERENCES savings_goals(id)
  )
''');

    // Create the investments table with investment_type, current_value, and purchase_date columns
    await db.execute('''
      CREATE TABLE investments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        investment_type TEXT,
        current_value REAL,
        amount_invested REAL,
        purchase_date TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');
  }

  // Handle database upgrades
  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN monthly_budget REAL DEFAULT 0');
    }
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
      double currentAmount, String targetDate) async {
    final db = await database;
    return await db.insert('savings_goals', {
      'user_id': userId,
      'goal_name': goalName,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate
    });
  }

  Future<int> addSavingEntry(int goalId, double amount, String date) async {
    final db = await database;
    await db.insert(
        'savings_entries', {'goal_id': goalId, 'amount': amount, 'date': date});

    // Update current amount in savings_goals
    await db.rawUpdate('''
    UPDATE savings_goals
    SET current_amount = current_amount + ?
    WHERE id = ?
  ''', [amount, goalId]);

    return goalId;
  }

  Future<List<Map<String, dynamic>>> getSavingsEntries(int goalId) async {
    final db = await database;
    return await db.query('savings_entries',
        where: 'goal_id = ?', whereArgs: [goalId], orderBy: 'date ASC');
  }

  Future<void> updateSavingsGoal(int id, String goalName, double targetAmount,
      double currentAmount, String targetDate) async {
    final db = await database;
    await db.update(
      'savings_goals',
      {
        'goal_name': goalName,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'target_date': targetDate,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSavingsGoal(int id) async {
    final db = await database;
    await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addInvestment(int userId, String investmentType,
      double currentValue, double amountInvested, String purchaseDate) async {
    final db = await database;
    return await db.insert('investments', {
      'user_id': userId,
      'investment_type': investmentType,
      'current_value': currentValue,
      'amount_invested': amountInvested,
      'purchase_date': purchaseDate
    });
  }

  Future<double> getTotalIncome(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM income WHERE user_id = ?', [userId]);
    return result.first['total'] != null
        ? result.first['total'] as double
        : 0.0;
  }

  Future<double> getTotalExpenses(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expense WHERE user_id = ?', [userId]);
    return result.first['total'] != null
        ? result.first['total'] as double
        : 0.0;
  }

  Future<double> getTotalSavings(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(target_amount) as total FROM savings_goals WHERE user_id = ?',
        [userId]);
    return result.first['total'] != null
        ? result.first['total'] as double
        : 0.0;
  }

  Future<double> getTotalInvestments(int userId) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount_invested) as total FROM investments WHERE user_id = ?',
        [userId]);
    return result.first['total'] != null
        ? result.first['total'] as double
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

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    var result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final db = await database;
    return await db.update('users', {'password': newPassword},
        where: 'email = ?', whereArgs: [email]);
  }

  Future<int> updateUser(
      int userId, String firstName, String lastName, String email) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
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

  Future<void> deleteIncome(int id) async {
    final db = await database;
    await db.delete('income', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateExpense(
      int id, double amount, String category, String date) async {
    final db = await database;
    await db.update(
      'expense',
      {
        'amount': amount,
        'category': category,
        'date': date,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete(
      'expense',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateInvestment(int id, String investmentType,
      double currentValue, double amountInvested, String purchaseDate) async {
    final db = await database;
    await db.update(
      'investments',
      {
        'investment_type': investmentType,
        'current_value': currentValue,
        'amount_invested': amountInvested,
        'purchase_date': purchaseDate,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteInvestment(int id) async {
    final db = await database;
    await db.delete(
      'investments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeByUserId(int userId) async {
    final db = await database;
    return await db.query('income',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'date DESC');
  }

  // Method to retrieve expenses for a specific user
  Future<List<Map<String, dynamic>>> getExpenses(int userId) async {
    final db = await database;
    return await db.query('expense',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'date DESC');
  }

  // Method to retrieve savings goals for a specific user
  Future<List<Map<String, dynamic>>> getSavingsGoals(int userId) async {
    final db = await database;
    return await db.query('savings_goals',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'target_date ASC');
  }

  // Method to retrieve investments for a specific user
  Future<List<Map<String, dynamic>>> getInvestments(int userId) async {
    final db = await database;
    return await db.query('investments',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'purchase_date DESC');
  }

  // Method to set user's monthly budget
  Future<void> setUserBudget(int userId, double budget) async {
    final db = await database;
    await db.update(
      'users',
      {'monthly_budget': budget},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Method to get user's monthly budget
  Future<double> getUserBudget(int userId) async {
    final db = await database;
    var result = await db.query('users',
        columns: ['monthly_budget'], where: 'id = ?', whereArgs: [userId]);

    return result.isNotEmpty && result.first['monthly_budget'] != null
        ? result.first['monthly_budget'] as double
        : 0.0;
  }

  // Method to get expenses grouped by category
  Future<List<Map<String, dynamic>>> getExpensesGroupedByCategory(
      int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT category, SUM(amount) as total_amount
      FROM expense
      WHERE user_id = ?
      GROUP BY category
    ''', [userId]);
  }

  // Method to get monthly income
  Future<List<Map<String, dynamic>>> getMonthlyIncome(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT substr(date, 1, 7) as date, SUM(amount) as total_amount
      FROM income
      WHERE user_id = ?
      GROUP BY substr(date, 1, 7)
      ORDER BY date ASC
    ''', [userId]);
  }

  // Get details of a specific goal
  Future<Map<String, dynamic>?> getGoal(int goalId) async {
    final db =
        await database; // Assume 'database' returns your database instance
    List<Map<String, dynamic>> result = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Add a savings entry
  Future<void> addSavingsEntry(int goalId, double amount, String date) async {
    final db = await database;
    await db.insert('savings_entries', {
      'goal_id': goalId,
      'amount': amount,
      'date': date,
    });
    // Update the current amount of the goal
    await updateGoalCurrentAmount(goalId, amount);
  }

  // Update the current amount of a specified goal
  Future<void> updateGoalCurrentAmount(int goalId, double amount) async {
    final db = await database;
    // Get the current amount for the goal
    final goal = await getGoal(goalId);
    if (goal != null) {
      double newCurrentAmount = goal['current_amount'] + amount;
      await db.update(
        'savings_goals',
        {'current_amount': newCurrentAmount},
        where: 'id = ?',
        whereArgs: [goalId],
      );
    }
  }

  // Update an existing savings entry
  Future<void> updateSavingsEntry(
      int entryId, double amount, String date) async {
    final db = await database;
    await db.update(
      'savings_entries',
      {'amount': amount, 'date': date},
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  // Delete a savings entry
  Future<void> deleteSavingsEntry(int entryId) async {
    final db = await database;
    await db.delete(
      'savings_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
    // Optionally, you may want to adjust the current amount of the related goal
    // after deleting the entry, based on the original amount of the entry.
  }
}
