// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QueuedDecisionsTable extends QueuedDecisions
    with TableInfo<$QueuedDecisionsTable, QueuedDecision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueuedDecisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookingReferenceMeta = const VerificationMeta(
    'bookingReference',
  );
  @override
  late final GeneratedColumn<String> bookingReference = GeneratedColumn<String>(
    'booking_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionTypeMeta = const VerificationMeta(
    'decisionType',
  );
  @override
  late final GeneratedColumn<String> decisionType = GeneratedColumn<String>(
    'decision_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _officerNameMeta = const VerificationMeta(
    'officerName',
  );
  @override
  late final GeneratedColumn<String> officerName = GeneratedColumn<String>(
    'officer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointOfEntryMeta = const VerificationMeta(
    'pointOfEntry',
  );
  @override
  late final GeneratedColumn<String> pointOfEntry = GeneratedColumn<String>(
    'point_of_entry',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookingReference,
    decisionType,
    notes,
    officerName,
    pointOfEntry,
    timestamp,
    synced,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queued_decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueuedDecision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('booking_reference')) {
      context.handle(
        _bookingReferenceMeta,
        bookingReference.isAcceptableOrUnknown(
          data['booking_reference']!,
          _bookingReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookingReferenceMeta);
    }
    if (data.containsKey('decision_type')) {
      context.handle(
        _decisionTypeMeta,
        decisionType.isAcceptableOrUnknown(
          data['decision_type']!,
          _decisionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_decisionTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('officer_name')) {
      context.handle(
        _officerNameMeta,
        officerName.isAcceptableOrUnknown(
          data['officer_name']!,
          _officerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officerNameMeta);
    }
    if (data.containsKey('point_of_entry')) {
      context.handle(
        _pointOfEntryMeta,
        pointOfEntry.isAcceptableOrUnknown(
          data['point_of_entry']!,
          _pointOfEntryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointOfEntryMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedDecision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedDecision(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      bookingReference:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}booking_reference'],
          )!,
      decisionType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}decision_type'],
          )!,
      notes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}notes'],
          )!,
      officerName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}officer_name'],
          )!,
      pointOfEntry:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}point_of_entry'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $QueuedDecisionsTable createAlias(String alias) {
    return $QueuedDecisionsTable(attachedDatabase, alias);
  }
}

class QueuedDecision extends DataClass implements Insertable<QueuedDecision> {
  final int id;
  final String bookingReference;
  final String decisionType;
  final String notes;
  final String officerName;
  final String pointOfEntry;
  final DateTime timestamp;
  final bool synced;
  final String? syncError;
  const QueuedDecision({
    required this.id,
    required this.bookingReference,
    required this.decisionType,
    required this.notes,
    required this.officerName,
    required this.pointOfEntry,
    required this.timestamp,
    required this.synced,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['booking_reference'] = Variable<String>(bookingReference);
    map['decision_type'] = Variable<String>(decisionType);
    map['notes'] = Variable<String>(notes);
    map['officer_name'] = Variable<String>(officerName);
    map['point_of_entry'] = Variable<String>(pointOfEntry);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  QueuedDecisionsCompanion toCompanion(bool nullToAbsent) {
    return QueuedDecisionsCompanion(
      id: Value(id),
      bookingReference: Value(bookingReference),
      decisionType: Value(decisionType),
      notes: Value(notes),
      officerName: Value(officerName),
      pointOfEntry: Value(pointOfEntry),
      timestamp: Value(timestamp),
      synced: Value(synced),
      syncError:
          syncError == null && nullToAbsent
              ? const Value.absent()
              : Value(syncError),
    );
  }

  factory QueuedDecision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuedDecision(
      id: serializer.fromJson<int>(json['id']),
      bookingReference: serializer.fromJson<String>(json['bookingReference']),
      decisionType: serializer.fromJson<String>(json['decisionType']),
      notes: serializer.fromJson<String>(json['notes']),
      officerName: serializer.fromJson<String>(json['officerName']),
      pointOfEntry: serializer.fromJson<String>(json['pointOfEntry']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookingReference': serializer.toJson<String>(bookingReference),
      'decisionType': serializer.toJson<String>(decisionType),
      'notes': serializer.toJson<String>(notes),
      'officerName': serializer.toJson<String>(officerName),
      'pointOfEntry': serializer.toJson<String>(pointOfEntry),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'synced': serializer.toJson<bool>(synced),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  QueuedDecision copyWith({
    int? id,
    String? bookingReference,
    String? decisionType,
    String? notes,
    String? officerName,
    String? pointOfEntry,
    DateTime? timestamp,
    bool? synced,
    Value<String?> syncError = const Value.absent(),
  }) => QueuedDecision(
    id: id ?? this.id,
    bookingReference: bookingReference ?? this.bookingReference,
    decisionType: decisionType ?? this.decisionType,
    notes: notes ?? this.notes,
    officerName: officerName ?? this.officerName,
    pointOfEntry: pointOfEntry ?? this.pointOfEntry,
    timestamp: timestamp ?? this.timestamp,
    synced: synced ?? this.synced,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  QueuedDecision copyWithCompanion(QueuedDecisionsCompanion data) {
    return QueuedDecision(
      id: data.id.present ? data.id.value : this.id,
      bookingReference:
          data.bookingReference.present
              ? data.bookingReference.value
              : this.bookingReference,
      decisionType:
          data.decisionType.present
              ? data.decisionType.value
              : this.decisionType,
      notes: data.notes.present ? data.notes.value : this.notes,
      officerName:
          data.officerName.present ? data.officerName.value : this.officerName,
      pointOfEntry:
          data.pointOfEntry.present
              ? data.pointOfEntry.value
              : this.pointOfEntry,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuedDecision(')
          ..write('id: $id, ')
          ..write('bookingReference: $bookingReference, ')
          ..write('decisionType: $decisionType, ')
          ..write('notes: $notes, ')
          ..write('officerName: $officerName, ')
          ..write('pointOfEntry: $pointOfEntry, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookingReference,
    decisionType,
    notes,
    officerName,
    pointOfEntry,
    timestamp,
    synced,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuedDecision &&
          other.id == this.id &&
          other.bookingReference == this.bookingReference &&
          other.decisionType == this.decisionType &&
          other.notes == this.notes &&
          other.officerName == this.officerName &&
          other.pointOfEntry == this.pointOfEntry &&
          other.timestamp == this.timestamp &&
          other.synced == this.synced &&
          other.syncError == this.syncError);
}

class QueuedDecisionsCompanion extends UpdateCompanion<QueuedDecision> {
  final Value<int> id;
  final Value<String> bookingReference;
  final Value<String> decisionType;
  final Value<String> notes;
  final Value<String> officerName;
  final Value<String> pointOfEntry;
  final Value<DateTime> timestamp;
  final Value<bool> synced;
  final Value<String?> syncError;
  const QueuedDecisionsCompanion({
    this.id = const Value.absent(),
    this.bookingReference = const Value.absent(),
    this.decisionType = const Value.absent(),
    this.notes = const Value.absent(),
    this.officerName = const Value.absent(),
    this.pointOfEntry = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
  });
  QueuedDecisionsCompanion.insert({
    this.id = const Value.absent(),
    required String bookingReference,
    required String decisionType,
    this.notes = const Value.absent(),
    required String officerName,
    required String pointOfEntry,
    required DateTime timestamp,
    this.synced = const Value.absent(),
    this.syncError = const Value.absent(),
  }) : bookingReference = Value(bookingReference),
       decisionType = Value(decisionType),
       officerName = Value(officerName),
       pointOfEntry = Value(pointOfEntry),
       timestamp = Value(timestamp);
  static Insertable<QueuedDecision> custom({
    Expression<int>? id,
    Expression<String>? bookingReference,
    Expression<String>? decisionType,
    Expression<String>? notes,
    Expression<String>? officerName,
    Expression<String>? pointOfEntry,
    Expression<DateTime>? timestamp,
    Expression<bool>? synced,
    Expression<String>? syncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookingReference != null) 'booking_reference': bookingReference,
      if (decisionType != null) 'decision_type': decisionType,
      if (notes != null) 'notes': notes,
      if (officerName != null) 'officer_name': officerName,
      if (pointOfEntry != null) 'point_of_entry': pointOfEntry,
      if (timestamp != null) 'timestamp': timestamp,
      if (synced != null) 'synced': synced,
      if (syncError != null) 'sync_error': syncError,
    });
  }

  QueuedDecisionsCompanion copyWith({
    Value<int>? id,
    Value<String>? bookingReference,
    Value<String>? decisionType,
    Value<String>? notes,
    Value<String>? officerName,
    Value<String>? pointOfEntry,
    Value<DateTime>? timestamp,
    Value<bool>? synced,
    Value<String?>? syncError,
  }) {
    return QueuedDecisionsCompanion(
      id: id ?? this.id,
      bookingReference: bookingReference ?? this.bookingReference,
      decisionType: decisionType ?? this.decisionType,
      notes: notes ?? this.notes,
      officerName: officerName ?? this.officerName,
      pointOfEntry: pointOfEntry ?? this.pointOfEntry,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookingReference.present) {
      map['booking_reference'] = Variable<String>(bookingReference.value);
    }
    if (decisionType.present) {
      map['decision_type'] = Variable<String>(decisionType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (officerName.present) {
      map['officer_name'] = Variable<String>(officerName.value);
    }
    if (pointOfEntry.present) {
      map['point_of_entry'] = Variable<String>(pointOfEntry.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueuedDecisionsCompanion(')
          ..write('id: $id, ')
          ..write('bookingReference: $bookingReference, ')
          ..write('decisionType: $decisionType, ')
          ..write('notes: $notes, ')
          ..write('officerName: $officerName, ')
          ..write('pointOfEntry: $pointOfEntry, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QueuedDecisionsTable queuedDecisions = $QueuedDecisionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [queuedDecisions];
}

typedef $$QueuedDecisionsTableCreateCompanionBuilder =
    QueuedDecisionsCompanion Function({
      Value<int> id,
      required String bookingReference,
      required String decisionType,
      Value<String> notes,
      required String officerName,
      required String pointOfEntry,
      required DateTime timestamp,
      Value<bool> synced,
      Value<String?> syncError,
    });
typedef $$QueuedDecisionsTableUpdateCompanionBuilder =
    QueuedDecisionsCompanion Function({
      Value<int> id,
      Value<String> bookingReference,
      Value<String> decisionType,
      Value<String> notes,
      Value<String> officerName,
      Value<String> pointOfEntry,
      Value<DateTime> timestamp,
      Value<bool> synced,
      Value<String?> syncError,
    });

class $$QueuedDecisionsTableFilterComposer
    extends Composer<_$AppDatabase, $QueuedDecisionsTable> {
  $$QueuedDecisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookingReference => $composableBuilder(
    column: $table.bookingReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionType => $composableBuilder(
    column: $table.decisionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pointOfEntry => $composableBuilder(
    column: $table.pointOfEntry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueuedDecisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueuedDecisionsTable> {
  $$QueuedDecisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookingReference => $composableBuilder(
    column: $table.bookingReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionType => $composableBuilder(
    column: $table.decisionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pointOfEntry => $composableBuilder(
    column: $table.pointOfEntry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueuedDecisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueuedDecisionsTable> {
  $$QueuedDecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookingReference => $composableBuilder(
    column: $table.bookingReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decisionType => $composableBuilder(
    column: $table.decisionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pointOfEntry => $composableBuilder(
    column: $table.pointOfEntry,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$QueuedDecisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueuedDecisionsTable,
          QueuedDecision,
          $$QueuedDecisionsTableFilterComposer,
          $$QueuedDecisionsTableOrderingComposer,
          $$QueuedDecisionsTableAnnotationComposer,
          $$QueuedDecisionsTableCreateCompanionBuilder,
          $$QueuedDecisionsTableUpdateCompanionBuilder,
          (
            QueuedDecision,
            BaseReferences<
              _$AppDatabase,
              $QueuedDecisionsTable,
              QueuedDecision
            >,
          ),
          QueuedDecision,
          PrefetchHooks Function()
        > {
  $$QueuedDecisionsTableTableManager(
    _$AppDatabase db,
    $QueuedDecisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$QueuedDecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$QueuedDecisionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$QueuedDecisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookingReference = const Value.absent(),
                Value<String> decisionType = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> officerName = const Value.absent(),
                Value<String> pointOfEntry = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => QueuedDecisionsCompanion(
                id: id,
                bookingReference: bookingReference,
                decisionType: decisionType,
                notes: notes,
                officerName: officerName,
                pointOfEntry: pointOfEntry,
                timestamp: timestamp,
                synced: synced,
                syncError: syncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookingReference,
                required String decisionType,
                Value<String> notes = const Value.absent(),
                required String officerName,
                required String pointOfEntry,
                required DateTime timestamp,
                Value<bool> synced = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
              }) => QueuedDecisionsCompanion.insert(
                id: id,
                bookingReference: bookingReference,
                decisionType: decisionType,
                notes: notes,
                officerName: officerName,
                pointOfEntry: pointOfEntry,
                timestamp: timestamp,
                synced: synced,
                syncError: syncError,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueuedDecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueuedDecisionsTable,
      QueuedDecision,
      $$QueuedDecisionsTableFilterComposer,
      $$QueuedDecisionsTableOrderingComposer,
      $$QueuedDecisionsTableAnnotationComposer,
      $$QueuedDecisionsTableCreateCompanionBuilder,
      $$QueuedDecisionsTableUpdateCompanionBuilder,
      (
        QueuedDecision,
        BaseReferences<_$AppDatabase, $QueuedDecisionsTable, QueuedDecision>,
      ),
      QueuedDecision,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QueuedDecisionsTableTableManager get queuedDecisions =>
      $$QueuedDecisionsTableTableManager(_db, _db.queuedDecisions);
}
