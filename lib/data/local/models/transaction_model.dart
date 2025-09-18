import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // e.g., 'income', 'expense'
  DateTimeColumn get date => dateTime()(); // including month and year
  TextColumn get category => text()();
  
  // New fields for enhanced transaction management
  TextColumn get accountId => text().nullable()(); // Account associated with the transaction
  TextColumn get time => text().nullable()(); // Time of the transaction
  TextColumn get repeat => text().nullable()(); // Repeat pattern (e.g., 'Daily', 'Weekly')
  TextColumn get remind => text().nullable()(); // Reminder settings
  TextColumn get icon => text().nullable()(); // Icon for the transaction
  TextColumn get color => text().nullable()(); // Color for the transaction
  TextColumn get notes => text().nullable()(); // Additional notes
  BoolColumn get paid => boolean().nullable()(); // Payment status (for expenses)
}