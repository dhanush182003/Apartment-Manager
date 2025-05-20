import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:apartment_manager/model/apartment_model.dart';
import 'package:apartment_manager/model/credit_model.dart';
import 'package:apartment_manager/model/debit_payment_model.dart';
import 'package:apartment_manager/model/report_model.dart';
import 'package:intl/intl.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'apartment_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE apartment (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            flatNo TEXT NOT NULL,
            name TEXT NOT NULL,
            mobile TEXT,
            email TEXT,
            role TEXT,
            tenantName TEXT,
            tenantEmail TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE credit_payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            apartmentId INTEGER NOT NULL,
            receiptNo TEXT,
            month TEXT,
            date TEXT,
            particular TEXT,
            amount REAL,
            userType TEXT,
            FOREIGN KEY (apartmentId) REFERENCES apartment(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
         CREATE TABLE debit_payments (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         apartmentId INTEGER NOT NULL,
         month TEXT,
         voucherNo TEXT,
        date TEXT,
        particular TEXT,
         paidTo TEXT,
         mobileNo TEXT,
        amount REAL,
        paymentMode TEXT,
        remarks TEXT,
        FOREIGN KEY (apartmentId) REFERENCES apartments(id)
  )
''');
      },
    );
  }

  // Insert a new apartment
  Future<int> insertApartment(ApartmentModel apartment) async {
    final db = await database;
    return await db.insert('apartment', apartment.toMap());
  }

  // Get all apartments
  Future<List<ApartmentModel>> getApartments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('apartment');
    return List.generate(maps.length, (i) {
      return ApartmentModel.fromMap(maps[i]);
    });
  }

  Future<List<CreditPaymentModel>> searchCreditPayments(
      int apartmentId, String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credit_payments',
      where: 'apartmentId = ? AND receiptNo LIKE ?',
      whereArgs: [apartmentId, '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return CreditPaymentModel.fromMap(maps[i]);
    });
  }

  // Update apartment
  Future<int> updateApartment(ApartmentModel apartment) async {
    final db = await database;
    return await db.update(
      'apartment',
      apartment.toMap(),
      where: 'id = ?',
      whereArgs: [apartment.id],
    );
  }

  // Delete apartment
  Future<int> deleteApartment(int id) async {
    final db = await database;
    return await db.delete(
      'apartment',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert a credit payment
  Future<int> insertCreditPayment(CreditPaymentModel payment) async {
    final db = await database;
    return await db.insert('credit_payments', payment.toMap());
  }

  // Get credit payments by apartmentId
  Future<List<CreditPaymentModel>> getCreditPayments(int apartmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credit_payments',
      where: 'apartmentId = ?',
      whereArgs: [apartmentId],
    );
    return List.generate(maps.length, (i) {
      return CreditPaymentModel.fromMap(maps[i]);
    });
  }

  // Get all credit payments (from all apartments)
  Future<List<CreditPaymentModel>> getAllCreditPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credit_payments',
      orderBy: 'date ASC', // or DESC for newest first
    );
    return List.generate(maps.length, (i) {
      return CreditPaymentModel.fromMap(maps[i]);
    });
  }

// Search all credit payments by receipt number (globally)
  Future<List<CreditPaymentModel>> searchAllCreditPayments(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credit_payments',
      where: 'receiptNo LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) {
      return CreditPaymentModel.fromMap(maps[i]);
    });
  }

  Future<int> updateCreditPayment(CreditPaymentModel payment) async {
    final db = await database;
    return await db.update(
      'credit_payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> insertDebitPayment(DebitPayment payment) async {
    final db = await database;
    return await db.insert('debit_payments', payment.toMap());
  }

// FETCH ALL
  Future<List<DebitPayment>> getAllDebitPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('debit_payments');
    return maps.map((map) => DebitPayment.fromMap(map)).toList();
  }

  Future<String> getNextReceiptNo(int apartmentId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(CAST(receiptNo AS INTEGER)) as maxNo FROM credit_payments WHERE apartmentId = ?',
      [apartmentId],
    );

    final maxNo = result.first['maxNo'];
    int nextNo = (maxNo == null) ? 1 : (int.parse(maxNo.toString()) + 1);
    return nextNo.toString();
  }

  Future<int> getNextVoucherNumber() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MAX(CAST(voucherNo AS INTEGER)) as max FROM debit_payments');
    final max = result.first['max'] as int?;
    return (max ?? 0) + 1;
  }

  Future<int> updateDebitPayment(DebitPayment payment) async {
    final db = await database;
    return db.update(
      'debit_payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<List<Map<String, String>>> getAccountStatement() async {
    final db = await database;
    final creditResults = await db.query('credit_payments');
    final debitResults = await db.query('debit_payments');

    List<Map<String, String>> combined = [];
    final formatter = DateFormat('dd-MM-yyyy');

    for (var row in creditResults) {
      final dt = DateTime.tryParse(row['date']?.toString() ?? '');
      if (dt == null) continue;
      combined.add({
        'date': formatter.format(dt),
        'particular': row['particular'].toString(),
        'credit': row['amount'].toString(),
        'debit': '-',
      });
    }

    for (var row in debitResults) {
      final dt = DateTime.tryParse(row['date']?.toString() ?? '');
      if (dt == null) continue;
      combined.add({
        'date': formatter.format(dt),
        'particular': row['particular'].toString(),
        'credit': '-',
        'debit': row['amount'].toString(),
      });
    }

    // Sort by date descending
    combined.sort((a, b) => b['date']!.compareTo(a['date']!));

    return combined;
  }

  Future<List<ReportModel>> fetchReportsForMonth(DateTime monthDate) async {
    final db = await database;
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0);

    final result = await db.query(
      'reports',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [firstDay.toIso8601String(), lastDay.toIso8601String()],
    );

    return result.map((json) => ReportModel.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTransactionsForMonth(
      DateTime date) async {
    final db = await _instance.database;
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    final start = DateFormat('yyyy-MM-dd').format(startOfMonth);
    final end = DateFormat('yyyy-MM-dd').format(endOfMonth);

    final creditResults = await db.query(
      'credit_payments',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
    );

    final debitResults = await db.query(
      'debit_payments',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
    );

    final credits = creditResults.map((e) => {
          'id': e['id'],
          'amount': _safeToDouble(e['amount']),
          'particular': e['particular'] ?? 'Others',
          'date': _safeDate(e['date']),
          'type': 'credit',
          'month': DateFormat('MMMM yyyy').format(_safeDate(e['date'])),
        });

    final debits = debitResults.map((e) => {
          'id': e['id'],
          'amount': _safeToDouble(e['amount']),
          'particular': e['particular'] ?? 'Others',
          'date': _safeDate(e['date']),
          'type': 'debit',
          'month': DateFormat('MMMM yyyy').format(_safeDate(e['date'])),
        });

    return [...credits, ...debits];
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  DateTime _safeDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return DateTime.now(); // fallback if parsing fails
      }
    }
    return DateTime.now(); // fallback if not string/date
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
