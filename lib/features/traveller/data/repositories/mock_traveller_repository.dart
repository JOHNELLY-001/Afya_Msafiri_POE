import '../../domain/repositories/traveller_repository.dart';
import '../models/traveller.dart';

class MockTravellerRepository implements TravellerRepository {
  /// Demo refs (case-insensitive substring match) so every risk level is
  /// reachable in mock mode:
  /// - ref containing "LOW"  → clean traveller → LOW RISK screen.
  /// - ref containing "HIGH" → flagged country + exposure + 3 symptoms
  ///   → HIGH RISK screen.
  /// - anything else → flagged country, no symptoms/exposure
  ///   → ELEVATED RISK screen (previous default fixture).
  @override
  Future<Traveller> fetchByBookingReference(String bookingReference) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final marker = bookingReference.toUpperCase();
    if (marker.contains('HIGH')) return _high(bookingReference);
    if (marker.contains('LOW')) return _low(bookingReference);
    return _elevated(bookingReference);
  }

  Traveller _base({
    required String bookingReference,
    required List<TravelHistoryEntry> travelHistory,
    required HealthScreening healthScreening,
  }) {
    return Traveller(
      firstName: 'John',
      middleName: 'Michael',
      lastName: 'Mushi',
      gender: 'Male',
      dateOfBirth: DateTime(1990, 4, 12),
      nationality: 'Tanzanian',
      passportId: 'AB1234821',
      bookingReference: bookingReference,
      arrivalDateTime: DateTime.now(),
      pointOfEntry: 'Dodoma Airport',
      portOfEntryUid: 'bRyC9c6ZQ2W',
      transportReference: 'KQ 762',
      seatNumber: '14C',
      reasonForTravel: 'Business',
      durationOfStayDays: 10,
      originCountry: 'Kenya',
      physicalAddress: 'Plot 45, Kinondoni',
      hotelName: 'Dodoma Grand Hotel',
      phoneNumber: '+255 712 345 678',
      email: 'john.mushi@example.com',
      travelHistory: travelHistory,
      healthScreening: healthScreening,
    );
  }

  Traveller _low(String bookingReference) {
    return _base(
      bookingReference: bookingReference,
      travelHistory: const [
        TravelHistoryEntry(country: 'Tanzania', period: 'Resident'),
      ],
      healthScreening: const HealthScreening(
        symptoms: [],
        otherSymptoms: null,
        visitedOutbreakArea: false,
        caredForSickPerson: false,
        participatedInBurial: false,
      ),
    );
  }

  Traveller _elevated(String bookingReference) {
    return _base(
      bookingReference: bookingReference,
      travelHistory: const [
        TravelHistoryEntry(country: 'Tanzania', period: 'Resident'),
        TravelHistoryEntry(country: 'Kenya', period: '12–15 Aug 2026'),
        TravelHistoryEntry(country: 'Uganda', period: '10–12 Aug 2026'),
      ],
      healthScreening: const HealthScreening(
        symptoms: [],
        otherSymptoms: null,
        visitedOutbreakArea: false,
        caredForSickPerson: false,
        participatedInBurial: false,
      ),
    );
  }

  Traveller _high(String bookingReference) {
    return _base(
      bookingReference: bookingReference,
      travelHistory: const [
        TravelHistoryEntry(country: 'Tanzania', period: 'Resident'),
        TravelHistoryEntry(country: 'Kenya', period: '12–15 Aug 2026'),
      ],
      healthScreening: const HealthScreening(
        symptoms: ['Fever/chills', 'Headache', 'Joint/Muscle pain'],
        otherSymptoms: null,
        visitedOutbreakArea: true,
        caredForSickPerson: true,
        participatedInBurial: false,
      ),
    );
  }

}