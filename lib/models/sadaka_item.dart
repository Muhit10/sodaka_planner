import 'package:uuid/uuid.dart';

class SadakaItem {
  final String id;
  String title;
  double amount;
  final DateTime date;
  bool isPaid;
  double paidAmount;

  SadakaItem({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    this.isPaid = false,
    this.paidAmount = 0.0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isPaid': isPaid,
      'paidAmount': paidAmount,
    };
  }

  factory SadakaItem.fromJson(Map<String, dynamic> json) {
    return SadakaItem(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      isPaid: json['isPaid'] ?? false,
      paidAmount: json['paidAmount'] ?? 0.0,
    );
  }
}
