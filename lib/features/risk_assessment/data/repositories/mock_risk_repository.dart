import '../../domain/repositories/risk_repository.dart';
import '../../../traveller/data/models/traveller.dart';
import '../models/risk_assessment_result.dart';
import '../models/risk_level.dart';

class MockRiskRepository implements RiskRepository {
  /// Real flagged-country list, as configured in AfyaMsafiri.
  static const List<String> _flaggedCountries = [
    'Kenya',
    'Central African Republic',
    'Liberia',
    'Gabon',
    'Congo (Democratic Republic of the)',
    'Uganda',
    'Nigeria',
    'Congo',
    'South Africa',
    'Ghana',
    "Cote d'Ivoire",
    'Rwanda',
    'Cameroon',
    'Guinea',
    'Morocco',
    'Burundi',
  ];

  @override
  Future<RiskAssessmentResult> assessTraveller(Traveller traveller) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final matchedCountry = traveller.travelHistory
        .map((e) => e.country)
        .firstWhere(
          (c) => _flaggedCountries.contains(c),
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
      explanation: _explain(level, countryMatch, matchedCountry, symptomCount, hasExposure),
      assessedAt: DateTime.now(),
      recommendation: _recommend(level),
    );
  }

  /// Combination table (see planning discussion):
  /// HIGH      — exposure + 3+ symptoms, OR (country match + exposure), OR (country match + 3+ symptoms)
  /// ELEVATED  — country match alone, OR exposure alone, OR 3+ symptoms alone, OR (country match + 1-2 symptoms)
  /// LOW       — everything else (0 symptoms, no match, no exposure; or 1-2 symptoms alone)
  RiskLevel _classify({
    required bool countryMatch,
    required int symptomCount,
    required bool hasExposure,
  }) {
    final heavySymptoms = symptomCount >= 3;
    final mildSymptoms = symptomCount >= 1 && symptomCount <= 2;

    if (hasExposure && heavySymptoms) return RiskLevel.high;
    if (countryMatch && hasExposure) return RiskLevel.high;
    if (countryMatch && heavySymptoms) return RiskLevel.high;

    if (countryMatch) return RiskLevel.elevated;
    if (hasExposure) return RiskLevel.elevated;
    if (heavySymptoms) return RiskLevel.elevated;
    if (countryMatch && mildSymptoms) return RiskLevel.elevated;

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
    if (countryMatch) parts.add('travel history includes $matchedCountry (flagged country)');
    if (hasExposure) parts.add('reported exposure to a sick or deceased person');
    if (symptomCount >= 3) {
      parts.add('$symptomCount symptoms reported');
    } else if (symptomCount >= 1) {
      parts.add('$symptomCount symptom(s) reported');
    }

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