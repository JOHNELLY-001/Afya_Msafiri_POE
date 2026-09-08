enum RiskLevel { low, elevated, high }

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'LOW RISK';
      case RiskLevel.elevated:
        return 'ELEVATED RISK';
      case RiskLevel.high:
        return 'HIGH RISK';
    }
  }
}