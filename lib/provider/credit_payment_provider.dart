import 'package:flutter/material.dart';
import 'package:apartment_manager/model/credit_model.dart';
import 'package:apartment_manager/db/db_helper.dart';

class CreditPaymentProvider with ChangeNotifier {
  final List<CreditPaymentModel> _allPayments = [];
  List<CreditPaymentModel> _creditPayments = [];

  List<CreditPaymentModel> get creditPayments => _creditPayments;

  final DBHelper _dbHelper = DBHelper();

  // Fetch all payments from all apartments
  Future<void> loadAllPayments() async {
    _creditPayments = await _dbHelper.getAllCreditPayments();
    notifyListeners();
  }

  // Fetch payments for a specific apartment
  Future<void> loadPayments(int apartmentId) async {
    _creditPayments = await _dbHelper.getCreditPayments(apartmentId);
    notifyListeners();
  }

  // Add new payment
  Future<void> addPayment(CreditPaymentModel payment) async {
    await _dbHelper.insertCreditPayment(payment);
    await loadAllPayments(); // Refresh all if we're listing globally
  }

  // Search payments globally by receipt number
  void searchPaymentsGlobally(String query) {
    final q = query.toLowerCase();
    _creditPayments = _allPayments.where((p) {
      return p.receiptNo.toLowerCase().contains(q) ||
          p.month.toLowerCase().contains(q) ||
          p.particular.toLowerCase().contains(q) ||
          p.amount.toString().contains(q);
    }).toList();
    notifyListeners();
  }

  // Search payments by receipt number for specific apartment
  Future<void> searchPayments(int apartmentId, String query) async {
    _creditPayments = await _dbHelper.searchCreditPayments(apartmentId, query);
    notifyListeners();
  }

  // Optional: Update a payment
  Future<void> updatePayment(CreditPaymentModel payment) async {
    await _dbHelper.updateCreditPayment(payment);
    await loadAllPayments();
  }

  // Optional: Delete a payment
  // Future<void> deletePayment(int id) async {
  //   await _dbHelper.deleteCreditPayment(id);
  //   await loadAllPayments();
  // }
}
