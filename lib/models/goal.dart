import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreGoal {
  final String id;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime creationDate;
  final DateTime targetDate;
  final bool isCompleted;
  final String userId;
  final String icon;
  final String? color;
  final String currency; // New field for currency

  FirestoreGoal({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.creationDate,
    required this.targetDate,
    this.isCompleted = false,
    required this.userId,
    required this.icon,
    this.color,
    required this.currency, // New required field
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'creationDate': Timestamp.fromDate(creationDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'isCompleted': isCompleted,
      'userId': userId,
      'icon': icon,
      'color': color,
      'currency': currency, // New field in JSON
    };
  }

  factory FirestoreGoal.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FirestoreGoal(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
      creationDate: (data['creationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetDate: (data['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      userId: data['userId'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'],
      currency: data['currency'] ?? 'USD', // New field with default
    );
  }

  factory FirestoreGoal.fromJson(Map<String, dynamic> json, String id) {
    final creationRaw = json['creationDate'];
    final targetRaw = json['targetDate'];

    DateTime creationDate;
    if (creationRaw is Timestamp) {
      creationDate = creationRaw.toDate();
    } else if (creationRaw is DateTime) {
      creationDate = creationRaw;
    } else {
      creationDate = DateTime.now();
    }

    DateTime targetDate;
    if (targetRaw is Timestamp) {
      targetDate = targetRaw.toDate();
    } else if (targetRaw is DateTime) {
      targetDate = targetRaw;
    } else {
      targetDate = DateTime.now();
    }

    return FirestoreGoal(
      id: id,
      name: json['name'] ?? '',
      description: json['description'],
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      creationDate: creationDate,
      targetDate: targetDate,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      userId: json['userId'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'],
      currency: json['currency'] ?? 'USD', // New field with default
    );
  }
}