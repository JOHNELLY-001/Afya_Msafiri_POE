import '../../domain/repositories/risk_repository.dart';
import '../../../traveller/data/models/traveller.dart';
import '../models/risk_assessment_result.dart';
import '../models/risk_level.dart';
import 'risk_countries_repository.dart';

/// Live implementation: flagged-country LIST comes from
/// `GET /riskcountries` (cached); matching/classification stays
/// client-side — same table as the mock:
///
/// HIGH     — exposure + 3+ symptoms, OR (country + exposure),
///            OR (country + 3+ symptoms)
/// ELEVATED — country alone, exposure alone, 3+ symptoms alone,
///            OR (country + 1-2 symptoms)
/// LOW      — everything else.
class ApiRiskRepository implements RiskRepository {
  ApiRiskRepository(this._countries);
  final RiskCountriesRepository _countries;

  @override
  Future<RiskAssessmentResult> assessTraveller(Traveller traveller) async {
    List<String> flagged;
    try {
      flagged = await _countries.fetchNames();
    } catch (_) {
      flagged = const [];
    }

    final matchedCountry = traveller.travelHistory
        .map((e) => e.country)
        .firstWhere(
          (c) => flagged.contains(c),
          orElse: () => '',
        );
    final countryMatch = matchedCountry.isNotEmpty;
    final symptomCount = traveller.healthScreening.symptomCount;
    final hasExposure = traveller.healthScreening.hasAnyExposure;
    final level = _classify(
      countryMatch: countryMatch,
      symptomCount: symptomCount,
      hasExposure: hasExposure,
    );

    return RiskAssessmentResult(
      level: level,
      countryMatch: countryMatch,
      matchedCountry: countryMatch ? matchedCountry : null,
      symptomCount: symptomCount,
      hasExposure: hasExposure,
      explanation:
          _explain(level, countryMatch, matchedCountry, symptomCount, hasExposure),
      assessedAt: DateTime.now(),
      recommendation: _recommend(level),
    );
  }

  RiskLevel _classify({
    required bool countryMatch,
    required int symptomCount,
    required bool hasExposure,
  }) {
    final heavySymptoms = symptomCount >= 3;
    if (hasExposure && heavySymptoms) return RiskLevel.high;
    if (countryMatch && hasExposure) return RiskLevel.high;
    if (countryMatch && heavySymptoms) return RiskLevel.high;
    if (countryMatch) return RiskLevel.elevated;
    if (hasExposure) return RiskLevel.elevated;
    if (heavySymptoms) return RiskLevel.elevated;
    return RiskLevel.low;
  }

  String _explain(
    RiskLevel level,
    bool countryMatch,
    String matchedCountry,
    int symptomCount,
    bool hasExposure,
  ) {
    final parts = <String>[];
    if (countryMatch) {
      parts.add('travel history includes $matchedCountry (flagged country)');
    }
    if (hasExposure) {
      parts.add('reported exposure to a sick or deceased person');
    }
    if (symptomCount >= 1) parts.add('$symptomCount symptom(s) reported');
    if (parts.isEmpty) {
      return 'No flagged travel history, exposure, or significant symptoms reported.';
    }
    return 'Based on: ${parts.join('; ')}.';
  }

  String _recommend(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Proceed with standard entry procedures.';
      case RiskLevel.elevated:
        return 'Review traveller and determine appropriate entry action.';
      case RiskLevel.high:
        return 'Review traveller and determine appropriate entry action immediately.';
    }
  }
}
