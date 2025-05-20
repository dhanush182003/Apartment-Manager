import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../model/report_model.dart';

class ReportProvider with ChangeNotifier {
  final List<ReportModel> _reports = [];
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  List<ReportModel> get reports => _reports;
  String get selectedMonth => _selectedMonth;

  double get totalCredit => _reports
      .where((e) => e.type == 'credit')
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalDebit => _reports
      .where((e) => e.type == 'debit')
      .fold(0.0, (sum, e) => sum + e.amount);

  double get balance => totalCredit - totalDebit;

  void changeMonth(String newMonth) {
    _selectedMonth = newMonth;
    loadReports();
  }

  Future<void> loadReports() async {
    final date = DateFormat('MMMM yyyy').parse(_selectedMonth);
    final result = await DBHelper().fetchReportsForMonth(date);
    _reports.clear();
    _reports.addAll(result);
    notifyListeners();
  }

  Map<String, double> get categoryWiseDebit {
    final map = <String, double>{};
    for (var e in _reports.where((e) => e.type == 'debit')) {
      map[e.particular] = (map[e.particular] ?? 0) + e.amount;
    }
    return map;
  }

  List<ReportModel> get topIncomes {
    final credits = _reports.where((e) => e.type == 'credit').toList();
    credits.sort((a, b) => b.amount.compareTo(a.amount));
    return credits.take(5).toList();
  }

  List<ReportModel> get topExpenses {
    final debits = _reports.where((e) => e.type == 'debit').toList();
    debits.sort((a, b) => b.amount.compareTo(a.amount));
    return debits.take(5).toList();
  }
}
