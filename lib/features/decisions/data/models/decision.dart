import 'decision_type.dart';

class Decision {
  final String bookingReference;
  final DecisionType type;
  final String notes;
  final String officerName;
  final String pointOfEntry;
  final DateTime timestamp;
  final bool synced;

  const Decision({
    required this.bookingReference,
    required this.type,
    required this.notes,
    required this.officerName,
    required this.pointOfEntry,
    required this.timestamp,
    required this.synced,
  });
}