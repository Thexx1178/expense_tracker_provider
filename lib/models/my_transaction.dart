// lib/models/transaction.dart
enum TransactionType { income, expense }

class MyTransaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  MyTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString(),
    };
  }

  factory MyTransaction.fromMap(Map<String, dynamic> map) {
    return MyTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: (map['type'] == TransactionType.income.toString())
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}