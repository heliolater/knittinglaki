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
/// A project can hold arbitrarily many counters. Counters have no title – they
/// are told apart by their position in the list.
class Counters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()
      .references(Projects, #id, onDelete: KeyAction.cascade)();

  /// Current round. Never negative – decrement clamps at 0.
  IntColumn get value => integer().withDefault(const Constant(0))();

  /// Manual ordering within the project. Lower comes first.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
