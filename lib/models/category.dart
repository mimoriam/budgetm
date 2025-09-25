import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String? name;
  final String? type; // e.g., 'income', 'expense'
  final String? icon;
  final String? color;
  final int displayOrder;

  Category({
    required this.id,
    this.name,
    this.type,
    this.icon,
    this.color,
    this.displayOrder = 0,
  });

  // Convert Category to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'displayOrder': displayOrder,
    };
  }

  // Create Category from Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'],
      type: data['type'],
      icon: data['icon'],
      color: data['color'],
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  // Create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json, String id) {
    return Category(
      id: id,
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  // Create a copy of Category with updated values
  Category copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    String? color,
    int? displayOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type, icon: $icon, color: $color, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.icon == icon &&
        other.color == color &&
        other.displayOrder == displayOrder;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, type, icon, color, displayOrder);
  }
}