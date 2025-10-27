import 'contracts.dart';

enum Recurrence { monthly, yearly }

class TransactionHistoryEntry {
  final String id;            // could map to an existing transaction ID
  final DateTime timestamp;   // when the charge happened (paidDate)
  final double amount;        // charge amount at that time
  final String? note;
  final DateTime? billingDate; // the date the payment was due
  final DateTime? paidDate;    // when user marked it as paid

  const TransactionHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.amount,
    this.note,
    this.billingDate,
    this.paidDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'amount': amount,
    'note': note,
    'billingDate': billingDate?.toIso8601String(),
    'paidDate': paidDate?.toIso8601String(),
  };

  factory TransactionHistoryEntry.fromJson(Map<String, dynamic> json) =>
      TransactionHistoryEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] as String?,
        billingDate: json['billingDate'] != null ? DateTime.parse(json['billingDate'] as String) : null,
        paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      );
}

class Subscription with DueDateContract {
  final String id;
  final String name;
  final double price;
  final bool isActive;
  final bool isPaused;         // NEW: track paused status separately from isActive
  final DateTime date;         // startDate (mandatory)
  final DateTime dueDate;      // mirrors nextBillingDate to satisfy cross-model constraints
  final DateTime nextBillingDate;
  final Recurrence recurrence;
  final String currency;       // currency code (e.g., 'USD', 'EUR')
  final List<TransactionHistoryEntry> history; // for detail view

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    this.isPaused = false,     // NEW: default to false
    required DateTime startDate,
    required this.nextBillingDate,
    required this.recurrence,
    required this.currency,
    List<TransactionHistoryEntry>? history,
  })  : date = startDate,
        dueDate = nextBillingDate,
        history = history ?? [] {
    validateDates();
    if (!isActive && history != null && history.isNotEmpty) {
      // Allowed but noteworthy: inactive subscriptions may still show past history
    }
  }

  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    bool? isActive,
    bool? isPaused,     // NEW: add isPaused parameter
    DateTime? startDate,
    DateTime? nextBillingDate,
    Recurrence? recurrence,
    String? currency,
    List<TransactionHistoryEntry>? history,
  }) {
    final effectiveStartDate = startDate ?? date;
    final effectiveNextBilling = nextBillingDate ?? this.nextBillingDate;
    final updated = Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,  // NEW: include isPaused
      startDate: effectiveStartDate,
      nextBillingDate: effectiveNextBilling,
      recurrence: recurrence ?? this.recurrence,
      currency: currency ?? this.currency,
      history: history ?? this.history,
    );
    return updated;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'isActive': isActive,
        'isPaused': isPaused,  // NEW: include isPaused in JSON
        'date': date.toIso8601String(),
        'dueDate': dueDate.toIso8601String(), // redundant mirror for uniformity
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'recurrence': recurrence.name,
        'currency': currency,
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final startDate = DateTime.parse(json['date'] as String);
    final nextBill = DateTime.parse(json['nextBillingDate'] as String);
    final sub = Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      isPaused: json['isPaused'] as bool? ?? false,  // NEW: handle isPaused with default
      startDate: startDate,
      nextBillingDate: nextBill,
      recurrence: Recurrence.values.firstWhere(
        (r) => r.name == json['recurrence'],
      ),
      currency: json['currency'] as String? ?? 'USD', // Default to USD if not present
      history: ((json['history'] as List?) ?? [])
          .map((e) => TransactionHistoryEntry.fromJson(e))
          .toList(),
    );
    return sub;
  }
}