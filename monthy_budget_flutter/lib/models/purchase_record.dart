import 'dart:convert';

class PurchaseRecord {
  final String id;
  final DateTime date;
  final double amount;
  final int itemCount;
  final List<String> items;

  const PurchaseRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.itemCount,
    this.items = const [],
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        itemCount: json['itemCount'] as int,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'itemCount': itemCount,
        'items': items,
      };
}

class PurchaseHistory {
  final List<PurchaseRecord> records;

  const PurchaseHistory({this.records = const []});

  double spentInMonth(int year, int month) => records
      .where((r) => r.date.year == year && r.date.month == month)
      .fold(0.0, (s, r) => s + r.amount);

  /// Returns a map of 'YYYY-MM' → total spent for each month that has records,
  /// sorted chronologically, limited to the last [months] months.
  Map<String, double> spentByMonth({int months = 6}) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - months + 1);
    final map = <String, double>{};
    for (final r in records) {
      if (r.date.isBefore(cutoff)) continue;
      final key = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + r.amount;
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

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
