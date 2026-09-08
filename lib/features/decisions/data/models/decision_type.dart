enum DecisionType { cleared, referred, quarantined }

extension DecisionTypeX on DecisionType {
  String get label {
    switch (this) {
      case DecisionType.cleared:
        return 'CLEAR';
      case DecisionType.referred:
        return 'REFER';
      case DecisionType.quarantined:
        return 'QUARANTINE';
    }
  }

  String get description {
    switch (this) {
      case DecisionType.cleared:
        return 'Traveller cleared for entry';
      case DecisionType.referred:
        return 'Refer for further screening';
      case DecisionType.quarantined:
        return 'Quarantine / isolation action required';
    }
  }
}