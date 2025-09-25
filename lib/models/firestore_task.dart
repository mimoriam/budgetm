import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTask {
  final String id;
  final String description;
  final double amount;
  final String type; // e.g., 'income', 'expense'
  final DateTime dueDate;
  final bool isCompleted;
  final String? categoryId;
  final String? accountId;
  final String? notes;

  FirestoreTask({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.dueDate,
    required this.isCompleted,
    this.categoryId,
    this.accountId,
    this.notes,
  });

  // Convert FirestoreTask to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'type': type,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'categoryId': categoryId,
      'accountId': accountId,
      'notes': notes,
    };
  }

  // Create FirestoreTask from Firestore document
  factory FirestoreTask.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FirestoreTask(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      categoryId: data['categoryId'],
      accountId: data['accountId'],
      notes: data['notes'],
    );
  }

  // Create FirestoreTask from JSON
  factory FirestoreTask.fromJson(Map<String, dynamic> json, String id) {
    return FirestoreTask(
      id: id,
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? '',
      dueDate: json['dueDate'] is Timestamp 
          ? (json['dueDate'] as Timestamp).toDate()
          : json['dueDate'] is DateTime
              ? json['dueDate']
              : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      notes: json['notes'],
    );
  }

  // Create a copy of FirestoreTask with updated values
  FirestoreTask copyWith({
    String? id,
    String? description,
    double? amount,
    String? type,
    DateTime? dueDate,
    bool? isCompleted,
    String? categoryId,
    String? accountId,
    String? notes,
  }) {
    return FirestoreTask(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'FirestoreTask(id: $id, description: $description, amount: $amount, type: $type, dueDate: $dueDate, isCompleted: $isCompleted, categoryId: $categoryId, accountId: $accountId, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirestoreTask &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.type == type &&
        other.dueDate == dueDate &&
        other.isCompleted == isCompleted &&
        other.categoryId == categoryId &&
        other.accountId == accountId &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id, description, amount, type, dueDate, isCompleted, categoryId, accountId, notes,
    );
  }
}