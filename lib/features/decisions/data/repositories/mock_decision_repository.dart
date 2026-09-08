import '../../domain/repositories/decision_repository.dart';
import '../models/decision.dart';

class MockDecisionRepository implements DecisionRepository {
  @override
  Future<Decision> submitDecision(Decision decision) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 5 will introduce real connectivity checks and offline queueing.
    // For now this always "succeeds" as if synced immediately.
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