import 'risk_level.dart';

class RiskAssessmentResult {
  final RiskLevel level;
  final String? matchedCountry;
  final String explanation;
  final DateTime assessedAt;
  final String recommendation;

  const RiskAssessmentResult({
    required this.level,
    this.matchedCountry,
    required this.explanation,
    required this.assessedAt,
    required this.recommendation,
  });
}