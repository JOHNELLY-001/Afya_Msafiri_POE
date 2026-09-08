import '../../domain/repositories/risk_repository.dart';
import '../../../traveller/data/models/traveller.dart';
import '../models/risk_assessment_result.dart';

/// Real DHIS2/AfyaMsafiri implementation.
///
/// TODO (Step 8 — API integration):
/// 1. Fetch the centrally configured risk-country list from the API
///    (cache locally so it works offline; refresh periodically).
/// 2. Match traveller.travelHistory against that list — this part of
///    the matching logic can likely stay client-side even after the
///    API swap, since it's fast and doesn't need network round-trips
///    per traveller. Only the risk-country LIST itself needs to come
///    from the API, not the matching decision.
class ApiRiskRepository implements RiskRepository {
  const ApiRiskRepository();

  @override
  Future<RiskAssessmentResult> assessTraveller(Traveller traveller) async {
    throw UnimplementedError(
      'ApiRiskRepository is not implemented yet. '
          'Set AppConfig.useMockData = true, or implement this method first.',
    );
  }
}