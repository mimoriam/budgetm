import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class Transaction {
  final int id; // Add database transaction ID
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final Widget icon;
  final Color iconBackgroundColor;
  final String? accountId; // Add accountId field
  final int? categoryId; // Add categoryId field

  Transaction({
    required this.id, // Add database transaction ID
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.icon,
    required this.iconBackgroundColor,
    this.accountId, // Add accountId field
    this.categoryId, // Add categoryId field
  });
}
