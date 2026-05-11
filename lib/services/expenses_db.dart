import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

class ExpensesDb {
  static final ExpensesDb _instance = ExpensesDb._internal();
  factory ExpensesDb() => _instance;
  ExpensesDb._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'mymoney.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            category TEXT,
            note TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<int> insert(Expense expense) async {
    final database = await db;
    return await database.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getAll() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<int> update(Expense expense) async {
    final database = await db;
    return await database.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final database = await db;
    return await database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalByMonth(int year, int month) async {
    final database = await db;
    
    // Format month to have leading zero if needed (e.g., '05' for May)
    final monthStr = month.toString().padLeft(2, '0');
    final prefix = '$year-$monthStr%';
    
    final result = await database.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date LIKE ?',
      [prefix],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> wipeAll() async {
    final database = await db;
    await database.delete('expenses');
  }
}
