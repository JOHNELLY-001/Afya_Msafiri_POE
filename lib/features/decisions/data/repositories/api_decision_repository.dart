import '../../domain/repositories/decision_repository.dart';
import '../models/decision.dart';

/// Real DHIS2/AfyaMsafiri implementation.
///
/// TODO (Step 8 — API integration):
/// 1. POST the decision to the backend (booking reference, decision type,
///    notes, officer id, POE, timestamp).
/// 2. On network failure, this should NOT throw silently — Step 5's
///    offline queue needs to catch that failure and store the decision
///    locally instead. Design this method to surface a distinguishable
///    exception type (e.g. NetworkException) so the queue logic can
///    tell "no connection" apart from "server rejected the request".
class ApiDecisionRepository implements DecisionRepository {
  const ApiDecisionRepository();

  @override
  Future<Decision> submitDecision(Decision decision) async {
    throw UnimplementedError(
      'ApiDecisionRepository is not implemented yet. '
          'Set AppConfig.useMockData = true, or implement this method first.',
    );
  }
}