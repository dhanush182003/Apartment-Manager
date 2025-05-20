import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../model/debit_payment_model.dart';

class DebitPaymentProvider extends ChangeNotifier {
  List<DebitPayment> _debitPayments = [];

  List<DebitPayment> get debitPayments => _debitPayments;

  Future<void> loadAllPayments() async {
    _debitPayments = await DBHelper().getAllDebitPayments();
    notifyListeners();
  }

  Future<void> addPayment(DebitPayment payment) async {
    await DBHelper().insertDebitPayment(payment);
    await loadAllPayments();
  }

  Future<String> getNextVoucherNumber() async {
    final nextNo = await DBHelper().getNextVoucherNumber();
    return nextNo.toString();
  }

  // Optional: add update/delete here
}
