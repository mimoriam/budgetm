import 'contracts.dart';

class Borrowed with DueDateContract {
  final String id;
  final String name;
  final String? description;
  final double price;
  final DateTime date;    // when borrowed
  final DateTime dueDate; // when due/expected return
  final bool returned;

  Borrowed({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.date,
    required this.dueDate,
    required this.returned,
  }) {
    validateDates();
  }

  Borrowed copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    DateTime? date,
    DateTime? dueDate,
    bool? returned,
  }) {
    final updated = Borrowed(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      returned: returned ?? this.returned,
    );
    return updated;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'date': date.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'returned': returned,
      };

  factory Borrowed.fromJson(Map<String, dynamic> json) => Borrowed(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        returned: json['returned'] as bool,
      );
}