import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id; // Composite key: {userId}_{categoryId}_{year}-{month}
  final String categoryId;
  final int year;
  final int month;
  final double spentAmount;
  final double limit; // New: optional spending limit for the category/month
  final String userId;

  Budget({
    required this.id,
    required this.categoryId,
    required this.year,
    required this.month,
    required this.spentAmount,
    required this.userId,
    double? limit,
  }) : limit = limit ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'year': year,
      'month': month,
      'spentAmount': spentAmount,
      'limit': limit,
      'userId': userId,
    };
  }

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      month: data['month'] ?? DateTime.now().month,
      spentAmount: (data['spentAmount'] as num?)?.toDouble() ?? 0.0,
      limit: (data['limit'] as num?)?.toDouble() ?? 0.0,
      userId: data['userId'] ?? '',
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json, String id) {
    return Budget(
      id: id,
      categoryId: json['categoryId'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      limit: (json['limit'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'] ?? '',
    );
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    int? year,
    int? month,
    double? spentAmount,
    double? limit,
    String? userId,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      year: year ?? this.year,
      month: month ?? this.month,
      spentAmount: spentAmount ?? this.spentAmount,
      limit: limit ?? this.limit,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, year: $year, month: $month, spentAmount: $spentAmount, limit: $limit, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.year == year &&
        other.month == month &&
        other.spentAmount == spentAmount &&
        other.limit == limit &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, categoryId, year, month, spentAmount, limit, userId);
  }

  // Helper method to generate budget ID
  static String generateId(String userId, String categoryId, int year, int month) {
    return '${userId}_${categoryId}_$year-${month.toString().padLeft(2, '0')}';
  }
}