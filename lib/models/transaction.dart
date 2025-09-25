import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final Widget icon;
  final Color iconBackgroundColor;
  final String? accountId;
  final String? categoryId;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.icon,
    required this.iconBackgroundColor,
    this.accountId,
    this.categoryId,
  });

  // Create a copy of Transaction with updated values
  Transaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? date,
    Widget? icon,
    Color? iconBackgroundColor,
    String? accountId,
    String? categoryId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      icon: icon ?? this.icon,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, description: $description, amount: $amount, type: $type, date: $date, accountId: $accountId, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.amount == amount &&
        other.type == type &&
        other.date == date &&
        other.accountId == accountId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id, title, description, amount, type, date, accountId, categoryId,
    );
  }
}
