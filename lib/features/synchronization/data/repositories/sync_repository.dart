import 'package:drift/drift.dart';

import '../../../decisions/data/models/decision.dart';
import '../../../decisions/data/models/decision_type.dart';
import '../../../decisions/domain/repositories/decision_repository.dart';
import '../local/app_database.dart';

class SyncRepository {
  SyncRepository(this._db, this._decisionRepository);

  final AppDatabase _db;
  final DecisionRepository _decisionRepository;

  /// Stores a decision locally, unsynced. Used when offline OR
  /// as a safety net if an online submission attempt fails.
  Future<void> enqueue(Decision decision) async {
    await _db.into(_db.queuedDecisions).insert(
      QueuedDecisionsCompanion.insert(
        bookingReference: decision.bookingReference,
        decisionType: decision.type.name,
        notes: Value(decision.notes),
        officerName: decision.officerName,
        pointOfEntry: decision.pointOfEntry,
        timestamp: decision.timestamp,
        synced: const Value(false),
      ),
    );
  }

  Stream<List<QueuedDecision>> watchPending() {
    return (_db.select(_db.queuedDecisions)
      ..where((t) => t.synced.equals(false)))
        .watch();
  }

  Stream<int> watchPendingCount() {
    return watchPending().map((rows) => rows.length);
  }

  Future<List<QueuedDecision>> getPending() {
    return (_db.select(_db.queuedDecisions)
      ..where((t) => t.synced.equals(false)))
        .get();
  }

  /// Attempts to sync all pending records.
  /// Returns (succeeded count, failed count).
  Future<(int, int)> syncAll() async {
    final pending = await getPending();
    var succeeded = 0;
    var failed = 0;

    for (final row in pending) {
      try {
        await _decisionRepository.submitDecision(
          Decision(
            bookingReference: row.bookingReference,
            type: DecisionType.values.byName(row.decisionType),
            notes: row.notes,
            officerName: row.officerName,
            pointOfEntry: row.pointOfEntry,
            timestamp: row.timestamp,
            synced: false,
          ),
        );

        await (_db.update(_db.queuedDecisions)..where((t) => t.id.equals(row.id))).write(
          const QueuedDecisionsCompanion(synced: Value(true), syncError: Value(null)),
        );
        succeeded++;
      } catch (e) {
        await (_db.update(_db.queuedDecisions)..where((t) => t.id.equals(row.id))).write(
          QueuedDecisionsCompanion(syncError: Value(e.toString())),
        );
        failed++;
        // TODO (token expiry, per plan): if `e` indicates an auth/401 error
        // specifically (not just "no network"), this is where we'd trigger
        // a re-auth prompt instead of silently leaving it queued as a
        // generic failure. ApiDecisionRepository (Step 8) should throw a
        // distinguishable exception type for this case.
      }
    }

    return (succeeded, failed);
  }

  Future<void> retryFailed() => syncAll();
}