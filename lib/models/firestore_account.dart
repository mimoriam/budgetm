import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAccount {
  final String id;
  final String name;
  final String accountType;
  final double balance;
  final String? description;
  final String? color;
  final String? icon;
  final String? currency;
  final double? creditLimit;
  final double? balanceLimit;
  final bool? isDefault;
  final DateTime? createdAt;
  final double? transactionLimit;

  FirestoreAccount({
    required this.id,
    required this.name,
    required this.accountType,
    required this.balance,
    this.description,
    this.color,
    this.icon,
    this.currency,
    this.creditLimit,
    this.balanceLimit,
    this.transactionLimit,
    this.isDefault,
    this.createdAt,
  });

  // Convert FirestoreAccount to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'accountType': accountType,
      'balance': balance,
      'description': description,
      'color': color,
      'icon': icon,
      'currency': currency,
      'creditLimit': creditLimit,
      'balanceLimit': balanceLimit,
      'transactionLimit': transactionLimit,
      'isDefault': isDefault,
      // For new accounts where createdAt is null, use server timestamp
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Create FirestoreAccount from Firestore document
  factory FirestoreAccount.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FirestoreAccount(
      id: doc.id,
      name: data['name'] ?? '',
      accountType: data['accountType'] ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      description: data['description'],
      color: data['color'],
      icon: data['icon'],
      currency: data['currency'],
      creditLimit: (data['creditLimit'] as num?)?.toDouble(),
      balanceLimit: (data['balanceLimit'] as num?)?.toDouble(),
      transactionLimit: (data['transactionLimit'] as num?)?.toDouble(),
      isDefault: data['isDefault'] as bool?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create FirestoreAccount from JSON
  factory FirestoreAccount.fromJson(Map<String, dynamic> json, String id) {
    final dynamic createdAtRaw = json['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = null;
    }
 
    return FirestoreAccount(
      id: id,
      name: json['name'] ?? '',
      accountType: json['accountType'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      color: json['color'],
      icon: json['icon'],
      currency: json['currency'],
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      balanceLimit: (json['balanceLimit'] as num?)?.toDouble(),
      transactionLimit: (json['transactionLimit'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool?,
      createdAt: createdAt,
    );
  }

  // Create a copy of FirestoreAccount with updated values
  FirestoreAccount copyWith({
    String? id,
    String? name,
    String? accountType,
    double? balance,
    String? description,
    String? color,
    String? icon,
    String? currency,
    double? creditLimit,
    double? balanceLimit,
    double? transactionLimit,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return FirestoreAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      currency: currency ?? this.currency,
      creditLimit: creditLimit ?? this.creditLimit,
      balanceLimit: balanceLimit ?? this.balanceLimit,
      transactionLimit: transactionLimit ?? this.transactionLimit,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FirestoreAccount(id: $id, name: $name, accountType: $accountType, balance: $balance, description: $description, color: $color, icon: $icon, currency: $currency, creditLimit: $creditLimit, balanceLimit: $balanceLimit, transactionLimit: $transactionLimit, isDefault: $isDefault, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirestoreAccount &&
        other.id == id &&
        other.name == name &&
        other.accountType == accountType &&
        other.balance == balance &&
        other.description == description &&
        other.color == color &&
        other.icon == icon &&
        other.currency == currency &&
        other.creditLimit == creditLimit &&
        other.balanceLimit == balanceLimit &&
        other.transactionLimit == transactionLimit &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id, name, accountType, balance, description, color, icon, currency, creditLimit, balanceLimit, transactionLimit, isDefault, createdAt,
    );
  }
}