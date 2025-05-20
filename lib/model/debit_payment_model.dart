class DebitPayment {
  final int? id;
  final int apartmentId;
  final String month;
  final String voucherNo;
  final String date;
  final String particular;
  final String paidTo;
  final String mobileNo;
  final double amount;
  final String paymentMode;
  final String remarks;

  DebitPayment({
    this.id,
    required this.apartmentId,
    required this.month,
    required this.voucherNo,
    required this.date,
    required this.particular,
    required this.paidTo,
    required this.mobileNo,
    required this.amount,
    required this.paymentMode,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'month': month,
      'voucherNo': voucherNo,
      'date': date,
      'particular': particular,
      'paidTo': paidTo,
      'mobileNo': mobileNo,
      'amount': amount,
      'paymentMode': paymentMode,
      'remarks': remarks,
    };
  }

  factory DebitPayment.fromMap(Map<String, dynamic> map) {
    return DebitPayment(
      id: map['id'],
      apartmentId: map['apartmentId'],
      month: map['month'],
      voucherNo: map['voucherNo'],
      date: map['date'],
      particular: map['particular'],
      paidTo: map['paidTo'],
      mobileNo: map['mobileNo'],
      amount: map['amount'],
      paymentMode: map['paymentMode'],
      remarks: map['remarks'],
    );
  }

  DebitPayment copyWith({
    String? month,
    String? date,
    String? particular,
    double? amount,
  }) {
    return DebitPayment(
      id: id,
      apartmentId: apartmentId,
      month: month ?? this.month,
      voucherNo: voucherNo,
      date: date ?? this.date,
      particular: particular ?? this.particular,
      paidTo: paidTo,
      mobileNo: mobileNo,
      amount: amount ?? this.amount,
      paymentMode: paymentMode,
      remarks: remarks,
    );
  }
}
