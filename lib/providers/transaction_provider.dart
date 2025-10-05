import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/my_transaction.dart';

class TransactionProvider with ChangeNotifier {
  Database? _database;
  List<MyTransaction> _transactions = [];

  List<MyTransaction> get transactions => _transactions;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transactions.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            note TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE transactions ADD COLUMN note TEXT;');
        }
      },
    );
  }

  Future<void> fetchAndSetTransactions() async {
    final db = await database;
    final data = await db.query('transactions', orderBy: 'date DESC');
    _transactions = data.map((row) => MyTransaction.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> addTransaction(MyTransaction tx) async {
    final db = await database;
    await db.insert('transactions', tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await fetchAndSetTransactions();
  }

  Future<void> updateTransaction(MyTransaction tx) async {
    final db = await database;
    await db.update('transactions', tx.toMap(),
        where: 'id = ?', whereArgs: [tx.id]);
    await fetchAndSetTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await fetchAndSetTransactions();
  }
}
