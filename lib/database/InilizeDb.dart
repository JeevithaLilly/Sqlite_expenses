import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> updateDatas(int id, Map<String, dynamic> newData) async {
    // Get the database
    print("new value....${newData}.....id");
    final db = await database;

    // Update the record in the first table where id is the given id
    await db.update(
      'expensesItem',
      newData,
      where: 'new value....id = ?',
      whereArgs: [id],
    );
  }
  Future<void> updateData(int id,Map<String, dynamic> item) async {
    print("new value....${item}.....id");
    final db = await database;
    await db.update('expensesItem', item, where: "id = ?", whereArgs: [item['id']]);
  }
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expenseApp.db');
    return await openDatabase(
      path,
      version: 3, // Increment the version when you add new tables
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expensesItem (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            title TEXT NOT NULL,
            amount TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE expenseDetailsCal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            value TEXT NOT NULL,
             uniqueID Text NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE anotherTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              description TEXT NOT NULL,
              value TEXT NOT NULL,
               uniqueID Text NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    await db.insert('expensesItem', expense, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertAnotherTable(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('expenseDetailsCal', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return await db.query('expensesItem');
  }

  Future<List<Map<String, dynamic>>> getAnotherTable() async {
    final db = await database;
    return await db.query('expenseDetailsCal');
  }

  Future<Map<String, dynamic>> getData(int matchingId) async {
    // Get the database
    final db = await database;

    // Query the first table where id is matchingId
    List<Map<String, dynamic>> expensesItemResults = await db.query(
      'expensesItem',
      where: 'id = ?',
      whereArgs: [matchingId],
    );

    // Query the second table where uniqueID is matchingId
    List<Map<String, dynamic>> expenseDetailsCalResults = await db.query(
      'expenseDetailsCal',
      where: 'uniqueID = ?',
      whereArgs: [matchingId.toString()],  // uniqueID is assumed to be a string
    );
// Sum the values in the 'value' field for all matching rows
    double totalValue = 0;
    for (var expense in expenseDetailsCalResults) {
      totalValue += double.tryParse(expense['value']) ?? 0;
    }
    // Combine results into a single map
    Map<String, dynamic> combinedResults = {
      'expensesItem': expensesItemResults.isNotEmpty ? expensesItemResults.first : null,
      'expensetable': expenseDetailsCalResults.isNotEmpty ? expenseDetailsCalResults : null,
      'totalValue': totalValue,
    };

    print("Expenses Item Results: $expensesItemResults");
    print("Expense Details Cal Results: $expenseDetailsCalResults");

    return combinedResults;
  }


  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete(
      'expensesItem',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}
