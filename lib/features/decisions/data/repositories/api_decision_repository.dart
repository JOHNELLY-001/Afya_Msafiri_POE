import '../../domain/repositories/decision_repository.dart';
import '../models/decision.dart';

/// Thrown when a repository has no server endpoint configured yet.
/// SyncRepository catches this and keeps the record queued on-device
/// (manual sync), instead of treating it as a network failure.
class EndpointNotConfiguredException implements Exception {
  final String feature;
  const EndpointNotConfiguredException(this.feature);

  @override
  String toString() =>
      'Kept on device — no server endpoint configured for $feature yet.';
}

/// Live mediator implementation — PENDING server endpoint.
///
/// The mediator (verified via its Swagger at `/api/`) currently exposes
/// bookings, clients, PoE centers, risk countries and certificates, but
/// NO decision/submission endpoint. Until the backend provides one,
/// [submitDecision] throws [EndpointNotConfiguredException] and every
/// decision is kept in the local Drift queue for MANUAL sync from the
/// Sync Center.
///
/// ===== SERVER CONFIG — fill this in when the endpoint exists =====
/// 1. Set [submitPath], e.g. '/decisions' or '/screeningDecisions'.
/// 2. Set [submitMethod] ('post', 'patch', …) to match the backend.
/// 3. Map [Decision] fields in [_payload]:
///    bookingReference → booking id, type.name → CLEAR/REFER/QUARANTINE
///    (confirm exact enum with backend), notes, officerName,
///    pointOfEntry, timestamp (ISO-8601).
/// 4. Inject the shared mediator Dio (see ApiTravellerRepository) via the
///    constructor and update decision_provider.dart to pass
///    `ref.watch(mediatorClientProvider)`.
/// 5. Delete the throw below and POST the payload with mediatorBody().
/// =================================================================
class ApiDecisionRepository implements DecisionRepository {
  const ApiDecisionRepository();

  /// CONFIG: server path for decision submission (unknown as of now).
  static const String submitPath = '';

  @override
  Future<Decision> submitDecision(Decision decision) async {
    throw const EndpointNotConfiguredException('entry decisions');
  }
}
