import '../../domain/repositories/risk_repository.dart';
import '../../../traveller/data/models/traveller.dart';
import '../models/risk_assessment_result.dart';
import '../models/risk_country.dart';
import '../models/risk_level.dart';

class MockRiskRepository implements RiskRepository {
  /// Static placeholder risk-country configuration.
  /// In production this comes from a centrally managed DHIS2 dataset,
  /// not hardcoded here — see ApiRiskRepository.
  static const List<RiskCountry> _riskCountries = [
    RiskCountry(
      country: 'Kenya',
      level: RiskLevel.elevated,
      reason: 'Under enhanced surveillance for a communicable disease outbreak.',
    ),
    RiskCountry(
      country: 'Democratic Republic of the Congo',
      level: RiskLevel.high,
      reason: 'Active outbreak classification requiring immediate review.',
    ),
  ];

  @override
  Future<RiskAssessmentResult> assessTraveller(Traveller traveller) async {
    await Future.delayed(const Duration(milliseconds: 500));

    RiskCountry? matched;
    for (final entry in traveller.travelHistory) {
      final match = _riskCountries.where((rc) => rc.country == entry.country);
      if (match.isNotEmpty) {
        final candidate = match.first;
        // Keep the highest-severity match if multiple countries match.
        if (matched == null || candidate.level.index > matched.level.index) {
          matched = candidate;
        }
      }
    }

    if (matched == null) {
      return RiskAssessmentResult(
        level: RiskLevel.low,
        explanation: 'No countries in this traveller\'s recent history are currently flagged.',
        assessedAt: DateTime.now(),
        recommendation: 'Proceed with standard entry procedures.',
      );
    }

    return RiskAssessmentResult(
      level: matched.level,
      matchedCountry: matched.country,
      explanation: matched.reason ?? 'Travel history matches a currently flagged country.',
      assessedAt: DateTime.now(),
      recommendation: matched.level == RiskLevel.high
          ? 'Review traveller and determine appropriate entry action immediately.'
          : 'Review traveller and determine appropriate entry action.',
    );
  }
}