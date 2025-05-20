class CreditPaymentModel {
  final int? id;
  final int apartmentId;
  final String receiptNo;
  final String month;
  final String date;
  final String particular;
  final double amount;
  final String userType;

  CreditPaymentModel({
    this.id,
    required this.apartmentId,
    required this.receiptNo,
    required this.month,
    required this.date,
    required this.particular,
    required this.amount,
    required this.userType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'receiptNo': receiptNo,
      'month': month,
      'date': date,
      'particular': particular,
      'amount': amount,
      'userType': userType,
    };
  }

  factory CreditPaymentModel.fromMap(Map<String, dynamic> map) {
    return CreditPaymentModel(
      id: map['id'],
      apartmentId: map['apartmentId'],
      receiptNo: map['receiptNo'],
      month: map['month'],
      date: map['date'],
      particular: map['particular'],
      amount: map['amount'],
      userType: map['userType'],
    );
  }
}
