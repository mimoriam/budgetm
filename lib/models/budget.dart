import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String name;
  final double totalAmount;
  final double currentAmount;
  final String categoryId;
  final DateTime endDate;
  final String userId;

  Budget({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.currentAmount,
    required this.categoryId,
    required this.endDate,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalAmount': totalAmount,
      'currentAmount': currentAmount,
      'categoryId': categoryId,
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
    };
  }

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      name: data['name'] ?? '',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
      categoryId: data['categoryId'] ?? '',
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json, String id) {
    return Budget(
      id: id,
      name: json['name'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] ?? '',
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : json['endDate'] is DateTime
              ? json['endDate']
              : DateTime.now(),
      userId: json['userId'] ?? '',
    );
  }

  Budget copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? currentAmount,
    String? categoryId,
    DateTime? endDate,
    String? userId,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      categoryId: categoryId ?? this.categoryId,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, name: $name, totalAmount: $totalAmount, currentAmount: $currentAmount, categoryId: $categoryId, endDate: $endDate, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.name == name &&
        other.totalAmount == totalAmount &&
        other.currentAmount == currentAmount &&
        other.categoryId == categoryId &&
        other.endDate == endDate &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, totalAmount, currentAmount, categoryId, endDate, userId);
  }
}