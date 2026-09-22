/// The full list of symptoms tracked on the real AfyaMsafiri screening form.
/// Labels match the live arrival booking form (arrivalMetadata/bookingForm)
// 1:1 so parsed mediator symptoms display identically.
class SymptomCatalog {
  SymptomCatalog._();

  static const List<String> all = [
    'Fever/chills',
    'Joint/Muscle pain',
    'Swollen glands',
    'Nausea/vomiting',
    'Coughing/Shortness breathing',
    'Skin Rash',
    'Jaundice',
    'General Body Weakness',
    'Headache',
    'Loss of appetite',
    'Chest pain',
    'Diarrhea',
    'Unusual bleeding',
    'Flu like symptoms',
    'Difficulty in swallowing',
    'Chills',
    'Paralysis',
  ];
}

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
  /// Symptoms marked "Yes" from SymptomCatalog.all.
  final List<String> symptoms;
  final String? otherSymptoms;

  // Exposure questions (Yes/No on the real form).
  final bool visitedOutbreakArea;
  final bool caredForSickPerson;
  final bool participatedInBurial;

  const HealthScreening({
    required this.symptoms,
    this.otherSymptoms,
    required this.visitedOutbreakArea,
    required this.caredForSickPerson,
    required this.participatedInBurial,
  });

  bool get hasAnyExposure =>
      visitedOutbreakArea || caredForSickPerson || participatedInBurial;

  int get symptomCount => symptoms.length;

  factory HealthScreening.fromJson(Map<String, dynamic> json) {
    return HealthScreening(
      symptoms: List<String>.from(json['symptoms'] ?? []),
      otherSymptoms: json['otherSymptoms'] as String?,
      visitedOutbreakArea: json['visitedOutbreakArea'] as bool? ?? false,
      caredForSickPerson: json['caredForSickPerson'] as bool? ?? false,
      participatedInBurial: json['participatedInBurial'] as bool? ?? false,
    );
  }
}

class Traveller {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String gender;
  final DateTime dateOfBirth;
  final String nationality;
  final String passportId;

  final String bookingReference;
  final DateTime arrivalDateTime;
  final String pointOfEntry;
  final String? portOfEntryUid;
  final String transportReference;
  final String? seatNumber;
  final String? reasonForTravel;
  final int? durationOfStayDays;
  final String? originCountry;

  final String? physicalAddress;
  final String? hotelName;
  final String phoneNumber;
  final String email;

  final List<TravelHistoryEntry> travelHistory;
  final HealthScreening healthScreening;

  const Traveller({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.nationality,
    required this.passportId,
    required this.bookingReference,
    required this.arrivalDateTime,
    required this.pointOfEntry,
    this.portOfEntryUid,
    required this.transportReference,
    this.seatNumber,
    this.reasonForTravel,
    this.durationOfStayDays,
    this.originCountry,
    this.physicalAddress,
    this.hotelName,
    required this.phoneNumber,
    required this.email,
    required this.travelHistory,
    required this.healthScreening,
  });

  String get fullName => [firstName, middleName, lastName]
      .where((p) => p != null && p.trim().isNotEmpty)
      .join(' ');

  factory Traveller.fromJson(Map<String, dynamic> json) {    return Traveller(
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      nationality: json['nationality'] as String,
      passportId: json['passportId'] as String,
      bookingReference: json['bookingReference'] as String,
      arrivalDateTime: DateTime.parse(json['arrivalDateTime'] as String),
      pointOfEntry: json['pointOfEntry'] as String,
      portOfEntryUid: json['portOfEntryUid'] as String?,
      transportReference: json['transportReference'] as String,
      seatNumber: json['seatNumber'] as String?,
      reasonForTravel: json['reasonForTravel'] as String?,
      durationOfStayDays: json['durationOfStayDays'] as int?,
      originCountry: json['originCountry'] as String?,
      physicalAddress: json['physicalAddress'] as String?,
      hotelName: json['hotelName'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      travelHistory: (json['travelHistory'] as List)
          .map((e) => TravelHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      healthScreening:
          HealthScreening.fromJson(json['healthScreening'] as Map<String, dynamic>),
    );
  }

  /// Tolerant parser for live mediator booking payloads.
  ///
  /// The mediator has three booking types (arrival / yellowFever /
  /// cardReplacement) with slightly different envelopes, and the exact
  /// success shape can only be confirmed with a real booking ID. This
  /// factory therefore:
  /// - unwraps `data`/`booking`/`result` envelopes,
  /// - looks for a nested client object (`client`, `traveller`, `person`)
  ///   or flat fields,
  /// - never throws `Null is not a subtype of String` — every field has
  ///   a fallback (QR [payload]/booking reference included).
  /// Refine the key map once a real `GET ...Booking/{id}` 200 body is
  /// captured from logcat.
  factory Traveller.fromMediatorJson(
    Map<String, dynamic> json, {
    required String fallbackBookingReference,
    DateTime? fallbackArrival,
    String? fallbackPoeUid,
  }) {
    Map<String, dynamic> root = json;
    for (final key in ['data', 'booking', 'result']) {
      final nested = root[key];
      if (nested is Map<String, dynamic>) {
        root = nested;
        break;
      } else if (nested is List && nested.isNotEmpty && nested.first is Map) {
        root = Map<String, dynamic>.from(nested.first as Map);
        break;
      }
    }

    Map<String, dynamic>? client;
    for (final key in ['client', 'traveller', 'person', 'owner', 'patient']) {
      final nested = root[key];
      if (nested is Map<String, dynamic>) {
        client = nested;
        break;
      }
    }
    client ??= root;

    String str(Object? v, [String fallback = '']) =>
        v?.toString().trim().isNotEmpty ?? false ? v.toString().trim() : fallback;
    String? optStr(Object? v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    // Gender / nationality may be {value,label} option objects.
    String pickOption(Object? v, [String fallback = '']) {
      if (v is Map) {
        return str(v['label'] ?? v['value'], fallback);
      }
      return str(v, fallback);
    }

    final identifiers = root['identifiers'] is List
        ? List.from(root['identifiers'] as List)
        : client['identifiers'] is List
            ? List.from(client['identifiers'] as List)
            : <dynamic>[];
    final passport = optStr(root['passport'] ??
            root['passportNumber'] ??
            root['passportNo'] ??
            client['passport'] ??
            client['passportNumber']) ??
        (identifiers.isNotEmpty ? identifiers.first.toString() : '');

    DateTime parseDate(Object? v, DateTime fallback) {
      if (v == null) return fallback;
      return DateTime.tryParse(v.toString()) ?? fallback;
    }

    final now = DateTime.now();
    final arrival = parseDate(
      root['arrivalDate'] ??
          root['bookingDate'] ??
          root['arrivalDateTime'] ??
          client['arrivalDate'],
      fallbackArrival ?? now,
    );
    final dob = parseDate(
      client['dateOfBirth'] ?? client['dob'] ?? client['birthDate'] ?? root['dateOfBirth'],
      DateTime(now.year - 30, 1, 1),
    );

    List<TravelHistoryEntry> historyFrom(dynamic v) {
      if (v is! List) return const [];
      return v.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        final country = str(
          m['country'] ?? m['label'] ?? m['name'] ?? m['value'],
        );
        final period = optStr(m['period'] ?? m['dateOfVisitCountry']);
        return TravelHistoryEntry(
          country: country.isEmpty ? 'Unknown' : country,
          period: period,
        );
      }).toList();
    }

    final travelHistory = historyFrom(root['countriesVisited'])
        .ifEmpty(historyFrom(root['travelHistory']))
        .ifEmpty(historyFrom(client['countriesVisited']));

    HealthScreening screeningFrom(Map<String, dynamic> src) {
      bool yes(Object? v) {
        if (v is bool) return v;
        final s = v?.toString().toLowerCase().trim();
        return s == 'true' || s == 'yes' || s == '1';
      }

      const symptomKeys = {
        'symptmFever': 'Fever/chills',
        'sympMusclePain': 'Joint/Muscle pain',
        'sympSwollenGlands': 'Swollen glands',
        'sympVomiting': 'Nausea/vomiting',
        'sympDifficultBreathing': 'Coughing/Shortness breathing',
        'sympSkinRash': 'Skin Rash',
        'sympJaundice': 'Jaundice',
        'sympBodyWeakness': 'General Body Weakness',
        'sympHeadache': 'Headache',
        'sympLossAppetite': 'Loss of appetite',
        'sympChestPain': 'Chest pain',
        'sympDiarrhea': 'Diarrhea',
        'sympUnusualBleeding': 'Unusual bleeding',
        'sympFlu': 'Flu like symptoms',
        'sympDifficultSwallowing': 'Difficulty in swallowing',
        'sympChills': 'Chills',
        'sympParalysis': 'Paralysis',
      };
      final symptoms = <String>[];
      // Flat code keys…
      for (final e in symptomKeys.entries) {
        if (yes(src[e.key])) symptoms.add(e.value);
      }
      // …or a nested symptoms map/list.
      final nested = src['symptoms'];
      if (nested is Map) {
        for (final e in symptomKeys.entries) {
          if (yes(nested[e.key]) && !symptoms.contains(e.value)) {
            symptoms.add(e.value);
          }
        }
      } else if (nested is List) {
        for (final s in nested) {
          final name = s.toString();
          if (!symptoms.contains(name)) symptoms.add(name);
        }
      }

      return HealthScreening(
        symptoms: symptoms,
        otherSymptoms: optStr(src['otherSymptoms'] ?? src['wzsQWMhoKwM']),
        visitedOutbreakArea: yes(src['exposureVisitedOutbreakArea'] ??
            src['visitedOutbreakArea']),
        caredForSickPerson: yes(
            src['exposureCareForSick'] ?? src['caredForSickPerson']),
        participatedInBurial: yes(src['exposureParticipateBurial'] ??
            src['participatedInBurial']),
      );
    }

    final screening =
        screeningFrom(root['healthConditions'] is Map ? Map<String, dynamic>.from(root['healthConditions'] as Map) : root);

    final bookingRef = str(
      root['bookingID'] ??
          root['bookingId'] ??
          root['bookingReference'] ??
          root['id'] ??
          root['uid'],
      fallbackBookingReference,
    );

    // Live arrival-form codes (arrivalMetadata/bookingForm):
    // VESSEL_NAME, VISITING_PURPOSE, DURATION_OF_STAY_TZ,
    // COUNTRY_JOURNEY_STARTED.
    return Traveller(
      firstName: str(client['firstName'] ?? root['firstName'], 'Traveller'),
      middleName: optStr(client['middleName'] ?? root['middleName']),
      lastName: str(
          client['surname'] ?? client['lastName'] ?? root['surname'] ?? root['lastName'], ''),
      gender: pickOption(client['gender'] ?? root['gender']),
      dateOfBirth: dob,
      nationality: pickOption(
          client['nationality'] ?? root['nationality'], 'Tanzanian'),
      passportId: passport,
      bookingReference: bookingRef,
      arrivalDateTime: arrival,
      pointOfEntry: str(
        root['portOfEntryName'] ?? root['pointOfEntry'] ?? client['portOfEntry'],
        'Point of Entry',
      ),
      portOfEntryUid: optStr(
              root['portOfEntry'] ?? root['portOfEntryUid'] ?? fallbackPoeUid) ??
          fallbackPoeUid,
      transportReference: str(
          root['transportReference'] ??
              root['vesselName'] ??
              root['flightNumber'] ??
              ''),
      seatNumber: optStr(root['seatNumber']),
      reasonForTravel: optStr(
          root['reasonForTravel'] ?? root['visitingPurpose'] ?? root['otherVisitingPurpose']),
      durationOfStayDays: int.tryParse((root['durationOfStayDays'] ??
              root['durationOfStayTz'] ??
              '')
          .toString()),
      originCountry: optStr(
          root['originCountry'] ?? root['countryJourneyStarted']),
      physicalAddress: optStr(root['physicalAddress']),
      hotelName: optStr(root['hotelName']),
      phoneNumber: str(
          client['phoneNumber'] ??
              client['phone'] ??
              root['phoneNumber'] ??
              root['phone'],
          ''),
      email: str(client['email'] ?? root['email'], ''),
      travelHistory: travelHistory,
      healthScreening: screening,
    );
  }
}

extension _IfEmpty<T> on List<T> {
  List<T> ifEmpty(List<T> other) => isEmpty ? other : this;
}