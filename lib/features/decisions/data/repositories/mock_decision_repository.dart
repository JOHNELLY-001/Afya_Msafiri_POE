import '../../domain/repositories/decision_repository.dart';
import '../models/decision.dart';

class MockDecisionRepository implements DecisionRepository {
  @override
  Future<Decision> submitDecision(Decision decision) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock mode (AppConfig.useMockData = true): decisions "succeed"
    // immediately as if synced. Live mode uses ApiDecisionRepository,
    // which queues to the on-device Drift store for manual sync until a
    // real server endpoint is configured (see its SERVER CONFIG).
    return Decision(
      bookingReference: decision.bookingReference,
      type: decision.type,
      notes: decision.notes,
      officerName: decision.officerName,
      pointOfEntry: decision.pointOfEntry,
      timestamp: decision.timestamp,
      synced: true,
    );
  }
}