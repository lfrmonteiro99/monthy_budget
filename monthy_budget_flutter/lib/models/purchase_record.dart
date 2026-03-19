import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'purchase_record.g.dart';

@JsonSerializable()
class PurchaseRecord {
  final String id;
  final DateTime date;
  final double amount;
  final int itemCount;
  final List<String> items;
  final bool isMealPurchase;

  const PurchaseRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.itemCount,
    this.items = const [],
    this.isMealPurchase = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseRecord &&
          id == other.id &&
          date == other.date &&
          amount == other.amount &&
          itemCount == other.itemCount &&
          isMealPurchase == other.isMealPurchase;

  @override
  int get hashCode =>
      Object.hash(id, date, amount, itemCount, isMealPurchase);

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) =>
      _$PurchaseRecordFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseRecordToJson(this);
}

@JsonSerializable(explicitToJson: true)
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
    return PurchaseHistory.fromJson({'records': list});
  }

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) =>
      _$PurchaseHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseHistoryToJson(this);
}
