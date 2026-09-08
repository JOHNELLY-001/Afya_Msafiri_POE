import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class QueuedDecisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookingReference => text()();
  TextColumn get decisionType => text()(); // stores DecisionType.name
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get officerName => text()();
  TextColumn get pointOfEntry => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncError => text().nullable()();
}

@DriftDatabase(tables: [QueuedDecisions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'afyamsafiri_manager.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}