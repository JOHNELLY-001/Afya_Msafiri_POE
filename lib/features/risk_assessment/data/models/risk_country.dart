import 'risk_level.dart';

class RiskCountry {
  final String country;
  final RiskLevel level;
  final String? reason;

  const RiskCountry({required this.country, required this.level, this.reason});

  factory RiskCountry.fromJson(Map<String, dynamic> json) {
    return RiskCountry(
      country: json['country'] as String,
      level: RiskLevel.values.byName(json['level'] as String),
      reason: json['reason'] as String?,
    );
  }
}