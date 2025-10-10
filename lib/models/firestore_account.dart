import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAccount {
  // Core fields for financial accounts (existing)
  final String id;
  final String name;
  final String accountType;
  final double balance;
  final String? description;
  final String? color;
  final String? icon;
 
  // Currency already existed for account; also reused by top-level account profile
  final String? currency;
 
  final double? creditLimit;
  final double? balanceLimit;
  final double? transactionLimit;
  final bool? isDefault;
  // Flag to indicate this account is a vacation account (new)
  final bool? isVacationAccount;
 
  // Timestamps and initialization metadata (extended for account profile at accounts/{uid})
  // Backward compatible: treat nulls safely.
  final bool? isInitialized; // default false if null when reading profile
  final DateTime? defaultCategoriesCreatedAt; // from Timestamp?
  final String? themeMode; // 'light' | 'dark' | 'system'
  final DateTime? createdAt; // from Timestamp (existing)
  final DateTime? updatedAt; // from Timestamp?

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
    this.isVacationAccount,
    this.isInitialized,
    this.defaultCategoriesCreatedAt,
    this.themeMode,
    this.createdAt,
    this.updatedAt,
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
      'isVacationAccount': isVacationAccount,
 
      // Initialization/profile fields (optional; only present for accounts/{uid} profile doc)
      'isInitialized': isInitialized,
      'defaultCategoriesCreatedAt': defaultCategoriesCreatedAt != null
          ? Timestamp.fromDate(defaultCategoriesCreatedAt!)
          : null,
      'themeMode': themeMode,
      // For new accounts where createdAt is null, use server timestamp
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create FirestoreAccount from Firestore document
  factory FirestoreAccount.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = (doc.data() as Map<String, dynamic>? ?? {});
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
      isVacationAccount: data['isVacationAccount'] as bool?,
 
      // Profile/initialization fields with backward compatibility
      isInitialized: data.containsKey('isInitialized') ? (data['isInitialized'] as bool?) ?? false : null,
      defaultCategoriesCreatedAt: (data['defaultCategoriesCreatedAt'] as Timestamp?)?.toDate(),
      themeMode: data['themeMode'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
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
 
    final dynamic updatedAtRaw = json['updatedAt'];
    DateTime? updatedAt;
    if (updatedAtRaw is Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    } else if (updatedAtRaw is DateTime) {
      updatedAt = updatedAtRaw;
    } else {
      updatedAt = null;
    }
 
    final dynamic defaultsCreatedRaw = json['defaultCategoriesCreatedAt'];
    DateTime? defaultCategoriesCreatedAt;
    if (defaultsCreatedRaw is Timestamp) {
      defaultCategoriesCreatedAt = defaultsCreatedRaw.toDate();
    } else if (defaultsCreatedRaw is DateTime) {
      defaultCategoriesCreatedAt = defaultsCreatedRaw;
    } else {
      defaultCategoriesCreatedAt = null;
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
      isVacationAccount: json['isVacationAccount'] as bool?,
      isInitialized: json.containsKey('isInitialized') ? (json['isInitialized'] as bool?) ?? false : null,
      defaultCategoriesCreatedAt: defaultCategoriesCreatedAt,
      themeMode: json['themeMode'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
    bool? isVacationAccount,
    bool? isInitialized,
    DateTime? defaultCategoriesCreatedAt,
    String? themeMode,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      isVacationAccount: isVacationAccount ?? this.isVacationAccount,
      isInitialized: isInitialized ?? this.isInitialized,
      defaultCategoriesCreatedAt: defaultCategoriesCreatedAt ?? this.defaultCategoriesCreatedAt,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FirestoreAccount('
        'id: $id, '
        'name: $name, '
        'accountType: $accountType, '
        'balance: $balance, '
        'description: $description, '
        'color: $color, '
        'icon: $icon, '
        'currency: $currency, '
        'creditLimit: $creditLimit, '
        'balanceLimit: $balanceLimit, '
        'transactionLimit: $transactionLimit, '
        'isDefault: $isDefault, '
        'isVacationAccount: $isVacationAccount, '
        'isInitialized: $isInitialized, '
        'defaultCategoriesCreatedAt: $defaultCategoriesCreatedAt, '
        'themeMode: $themeMode, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
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
        other.isVacationAccount == isVacationAccount &&
        other.isInitialized == isInitialized &&
        other.defaultCategoriesCreatedAt == defaultCategoriesCreatedAt &&
        other.themeMode == themeMode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      accountType,
      balance,
      description,
      color,
      icon,
      currency,
      creditLimit,
      balanceLimit,
      transactionLimit,
      isDefault,
      isVacationAccount,
      isInitialized,
      defaultCategoriesCreatedAt,
      themeMode,
      createdAt,
      updatedAt,
    );
  }
}