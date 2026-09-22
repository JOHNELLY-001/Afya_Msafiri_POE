import 'risk_level.dart';

class RiskAssessmentResult {
  final RiskLevel level;
  final bool countryMatch;
  final String? matchedCountry;
  final int symptomCount;
  final bool hasExposure;
  final String explanation;
  final DateTime assessedAt;
  final String recommendation;

  const RiskAssessmentResult({
    required this.level,
    required this.countryMatch,
    this.matchedCountry,
    required this.symptomCount,
    required this.hasExposure,
    required this.explanation,
    required this.assessedAt,
    required this.recommendation,
  });
}