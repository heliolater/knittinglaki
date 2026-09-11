import 'package:drift/drift.dart';

/// A knitting/crochet project, e.g. "Socken" or "Schal".
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Manual ordering in the project list. Lower comes first.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// A single round counter that belongs to a [Projects] row.
///
/// A project can hold arbitrarily many counters. Every counter gets an
/// auto-generated name ("Zähler N", N = counter count at creation time) that
/// can be renamed afterwards; it does not change when counters are reordered
/// or deleted.
class Counters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()
      .references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Current round. Never negative – decrement clamps at 0.
  IntColumn get value => integer().withDefault(const Constant(0))();

  /// Manual ordering within the project. Lower comes first.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
