class TravelHistoryEntry {
  final String country;
  final String? period;

  const TravelHistoryEntry({required this.country, this.period});

  factory TravelHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TravelHistoryEntry(
      country: json['country'] as String,
      period: json['period'] as String?,
    );
  }
}

class HealthScreening {
  final String vaccinationStatus;
  final List<String> reportedSymptoms;
  final Map<String, String> additionalAnswers;

  const HealthScreening({
    required this.vaccinationStatus,
    required this.reportedSymptoms,
    this.additionalAnswers = const {},
  });

  factory HealthScreening.fromJson(Map<String, dynamic> json) {
    return HealthScreening(
      vaccinationStatus: json['vaccinationStatus'] as String,
      reportedSymptoms: List<String>.from(json['reportedSymptoms'] ?? []),
      additionalAnswers: Map<String, String>.from(json['additionalAnswers'] ?? {}),
    );
  }
}

class Traveller {
  final String name;
  final String passportId;
  final String nationality;
  final String bookingReference;
  final DateTime arrivalDateTime;
  final String pointOfEntry;
  final String transportReference;
  final List<TravelHistoryEntry> travelHistory;
  final HealthScreening healthScreening;

  const Traveller({
    required this.name,
    required this.passportId,
    required this.nationality,
    required this.bookingReference,
    required this.arrivalDateTime,
    required this.pointOfEntry,
    required this.transportReference,
    required this.travelHistory,
    required this.healthScreening,
  });

  /// Matches the shape we expect from the DHIS2/AfyaMsafiri API.
  /// Once real integration starts, this factory is where field-name
  /// mapping adjustments happen — nothing else in the app needs to change.
  factory Traveller.fromJson(Map<String, dynamic> json) {
    return Traveller(
      name: json['name'] as String,
      passportId: json['passportId'] as String,
      nationality: json['nationality'] as String,
      bookingReference: json['bookingReference'] as String,
      arrivalDateTime: DateTime.parse(json['arrivalDateTime'] as String),
      pointOfEntry: json['pointOfEntry'] as String,
      transportReference: json['transportReference'] as String,
      travelHistory: (json['travelHistory'] as List)
          .map((e) => TravelHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      healthScreening: HealthScreening.fromJson(json['healthScreening'] as Map<String, dynamic>),
    );
  }
}