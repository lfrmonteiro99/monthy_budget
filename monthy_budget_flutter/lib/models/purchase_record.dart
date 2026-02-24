import 'dart:convert';

class PurchaseRecord {
  final String id;
  final DateTime date;
  final double amount;
  final int itemCount;

  const PurchaseRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.itemCount,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        itemCount: json['itemCount'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'itemCount': itemCount,
      };
}

class PurchaseHistory {
  final List<PurchaseRecord> records;

  const PurchaseHistory({this.records = const []});

  double spentInMonth(int year, int month) => records
      .where((r) => r.date.year == year && r.date.month == month)
      .fold(0.0, (s, r) => s + r.amount);

  String toJsonString() => jsonEncode(records.map((r) => r.toJson()).toList());

  factory PurchaseHistory.fromJsonString(String s) {
    final list = jsonDecode(s) as List<dynamic>;
    return PurchaseHistory(
      records: list
          .map((e) => PurchaseRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
