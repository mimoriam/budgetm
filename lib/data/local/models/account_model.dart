import 'package:drift/drift.dart';

class Accounts extends Table {
  TextColumn get id => text().unique()();
  TextColumn get name => text()();
  TextColumn get accountType => text()(); // New required field
  RealColumn get creditLimit => real().nullable()(); // New nullable field
  RealColumn get balanceLimit => real().nullable()(); // New nullable field
  RealColumn get balance => real().withDefault(Constant(0.0))();
  TextColumn get currency => text()();
  BoolColumn get isDefault => boolean().withDefault(Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}