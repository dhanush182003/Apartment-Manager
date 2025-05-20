class ReportModel {
  final String month;
  final double amount;
  final String type;
  final String particular;
  final DateTime date;

  ReportModel({
    required this.month,
    required this.amount,
    required this.type,
    required this.particular,
    required this.date,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      month: map['month'] ?? '',
      amount: _toDouble(map['amount']),
      type: map['type'] ?? '',
      particular: map['particular'] ?? 'Others',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'amount': amount,
      'type': type,
      'particular': particular,
      'date': date.toIso8601String(),
    };
  }
}

// Helper function outside the class
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
