import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // e.g., 'income', 'expense'
  DateTimeColumn get date => dateTime()(); // including month and year
  TextColumn get category => text()();
}