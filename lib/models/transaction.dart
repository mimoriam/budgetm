import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class Transaction {
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final Widget icon;
  final Color iconBackgroundColor;

  Transaction({
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.icon,
    required this.iconBackgroundColor,
  });
}
