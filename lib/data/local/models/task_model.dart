import 'package:drift/drift.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // e.g., 'income', 'expense'
  DateTimeColumn get dueDate => dateTime()();
  BoolColumn get isCompleted => boolean()();
}