import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTransaction {
  final String id;
  final String description;
  final double amount;
  final String type; // e.g., 'income', 'expense'
  final DateTime date;
  final String? categoryId;
  final String? accountId;
  final String? time;
  final String? repeat;
  final String? remind;
  final String? icon;
  final String? color;
  final String? notes;
  final bool? paid;
  final bool isVacation;

  FirestoreTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.categoryId,
    this.accountId,
    this.time,
    this.repeat,
    this.remind,
    this.icon,
    this.color,
    this.notes,
    this.paid,
    this.isVacation = false,
  });

  // Convert FirestoreTransaction to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'accountId': accountId,
      'time': time,
      'repeat': repeat,
      'remind': remind,
      'icon': icon,
      'color': color,
      'notes': notes,
      'paid': paid,
      'isVacation': isVacation,
    };
  }

  // Create FirestoreTransaction from Firestore document
  factory FirestoreTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FirestoreTransaction(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryId: data['categoryId'],
      accountId: data['accountId'],
      time: data['time'],
      repeat: data['repeat'],
      remind: data['remind'],
      icon: data['icon'],
      color: data['color'],
      notes: data['notes'],
      paid: data['paid'],
      isVacation: data['isVacation'] ?? false,
    );
  }

  // Create FirestoreTransaction from JSON
  factory FirestoreTransaction.fromJson(Map<String, dynamic> json, String id) {
    return FirestoreTransaction(
      id: id,
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : json['date'] is DateTime
              ? json['date']
              : DateTime.now(),
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      time: json['time'],
      repeat: json['repeat'],
      remind: json['remind'],
      icon: json['icon'],
      color: json['color'],
      notes: json['notes'],
      paid: json['paid'],
      isVacation: json['isVacation'] ?? false,
    );
  }

  // Create a copy of FirestoreTransaction with updated values
  FirestoreTransaction copyWith({
    String? id,
    String? description,
    double? amount,
    String? type,
    DateTime? date,
    String? categoryId,
    String? accountId,
    String? time,
    String? repeat,
    String? remind,
    String? icon,
    String? color,
    String? notes,
    bool? paid,
    bool? isVacation,
  }) {
    return FirestoreTransaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      remind: remind ?? this.remind,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      paid: paid ?? this.paid,
      isVacation: isVacation ?? this.isVacation,
    );
  }

  @override
  String toString() {
    return 'FirestoreTransaction(id: $id, description: $description, amount: $amount, type: $type, date: $date, categoryId: $categoryId, accountId: $accountId, time: $time, repeat: $repeat, remind: $remind, icon: $icon, color: $color, notes: $notes, paid: $paid, isVacation: $isVacation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirestoreTransaction &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.type == type &&
        other.date == date &&
        other.categoryId == categoryId &&
        other.accountId == accountId &&
        other.time == time &&
        other.repeat == repeat &&
        other.remind == remind &&
        other.icon == icon &&
        other.color == color &&
        other.notes == notes &&
        other.paid == paid &&
        other.isVacation == isVacation;
  }

  @override
  int get hashCode {
    return Object.hash(
      id, description, amount, type, date, categoryId, accountId,
      time, repeat, remind, icon, color, notes, paid, isVacation,
    );
  }
}