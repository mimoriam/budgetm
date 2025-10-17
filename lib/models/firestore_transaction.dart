import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTransaction {
  final String id;
  final String description;
  final double amount;
  final String type; // e.g., 'income', 'expense'
  final DateTime date;
  final String currency;
  final String? categoryId;
  final String? budgetId;
  final String? goalId;
  final String? accountId;
  final String? time;
  final String? repeat;
  final String? remind;
  final String? icon;
  final String? color;
  final String? icon_color;
  final String? notes;
  final bool? paid;
  final bool isVacation;
  final String? linkedTransactionId;

  FirestoreTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.currency,
    this.categoryId,
    this.budgetId,
    this.goalId,
    this.accountId,
    this.time,
    this.repeat,
    this.remind,
    this.icon,
    this.color,
    this.icon_color,
    this.notes,
    this.paid,
    this.isVacation = false,
    this.linkedTransactionId,
  });

  // Convert FirestoreTransaction to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'currency': currency,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'goalId': goalId,
      'accountId': accountId,
      'time': time,
      'repeat': repeat,
      'remind': remind,
      'icon': icon,
      'color': color,
      'icon_color': icon_color,
      'notes': notes,
      'paid': paid,
      'isVacation': isVacation,
      'linkedTransactionId': linkedTransactionId,
    };
  }

  // Create FirestoreTransaction from Firestore data (type-safe for Map<String, Object?>)
  factory FirestoreTransaction.fromFirestore(Map<String, Object?> data, String id) {
    return FirestoreTransaction(
      id: id,
      description: (data['description'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: (data['type'] as String?) ?? '',
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : data['date'] is DateTime
              ? (data['date'] as DateTime)
              : DateTime.now(),
      currency: data['currency'] as String? ?? 'USD',
      categoryId: data['categoryId'] as String?,
      budgetId: data['budgetId'] as String?,
      goalId: data['goalId'] as String?,
      accountId: data['accountId'] as String?,
      time: data['time'] as String?,
      repeat: data['repeat'] as String?,
      remind: data['remind'] as String?,
      icon: data['icon'] as String?,
      color: data['color'] as String?,
      icon_color: data['icon_color'] as String?,
      notes: data['notes'] as String?,
      // Default: expenses are considered paid unless explicitly set; others default to false
      paid: (data['paid'] as bool?) ?? ((data['type'] as String?) == 'expense' ? true : false),
      isVacation: (data['isVacation'] as bool?) ?? false,
      linkedTransactionId: data['linkedTransactionId'] as String?,
    );
  }

  // Convert FirestoreTransaction to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'currency': currency,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'goalId': goalId,
      'accountId': accountId,
      'time': time,
      'repeat': repeat,
      'remind': remind,
      'icon': icon,
      'color': color,
      'icon_color': icon_color,
      'notes': notes,
      'paid': paid,
      'isVacation': isVacation,
      'linkedTransactionId': linkedTransactionId,
    };
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
      currency: json['currency'] ?? 'USD',
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      goalId: json['goalId'],
      accountId: json['accountId'],
      time: json['time'],
      repeat: json['repeat'],
      remind: json['remind'],
      icon: json['icon'],
      color: json['color'],
      icon_color: json['icon_color'],
      notes: json['notes'],
      paid: json['paid'],
      isVacation: json['isVacation'] ?? false,
      linkedTransactionId: json['linkedTransactionId'],
    );
  }

  // Create a copy of FirestoreTransaction with updated values
  FirestoreTransaction copyWith({
    String? id,
    String? description,
    double? amount,
    String? type,
    DateTime? date,
    String? currency,
    String? categoryId,
    String? budgetId,
    String? goalId,
    String? accountId,
    String? time,
    String? repeat,
    String? remind,
    String? icon,
    String? color,
    String? icon_color,
    String? notes,
    bool? paid,
    bool? isVacation,
    String? linkedTransactionId,
  }) {
    return FirestoreTransaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      goalId: goalId ?? this.goalId,
      accountId: accountId ?? this.accountId,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      remind: remind ?? this.remind,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      icon_color: icon_color ?? this.icon_color,
      notes: notes ?? this.notes,
      paid: paid ?? this.paid,
      isVacation: isVacation ?? this.isVacation,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
    );
  }

  @override
  String toString() {
    return 'FirestoreTransaction(id: $id, description: $description, amount: $amount, type: $type, date: $date, currency: $currency, categoryId: $categoryId, budgetId: $budgetId, goalId: $goalId, accountId: $accountId, time: $time, repeat: $repeat, remind: $remind, icon: $icon, color: $color, icon_color: $icon_color, notes: $notes, paid: $paid, isVacation: $isVacation, linkedTransactionId: $linkedTransactionId)';
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
        other.currency == currency &&
        other.categoryId == categoryId &&
        other.budgetId == budgetId &&
        other.goalId == goalId &&
        other.accountId == accountId &&
        other.time == time &&
        other.repeat == repeat &&
        other.remind == remind &&
        other.icon == icon &&
        other.color == color &&
        other.icon_color == icon_color &&
        other.notes == notes &&
        other.paid == paid &&
        other.isVacation == isVacation &&
        other.linkedTransactionId == linkedTransactionId;
  }
 
  @override
  int get hashCode {
    return Object.hash(
      id, description, amount, type, date, currency, categoryId, budgetId, goalId, accountId,
      time, repeat, remind, icon, color, icon_color, notes, paid, isVacation,
      linkedTransactionId,
    );
  }
}