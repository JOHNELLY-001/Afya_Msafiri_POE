import '../../domain/repositories/traveller_repository.dart';
import '../models/traveller.dart';

class MockTravellerRepository implements TravellerRepository {
  @override
  Future<Traveller> fetchByBookingReference(String bookingReference) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return Traveller(
      name: 'John Michael',
      passportId: 'AB1234821',
      nationality: 'Tanzanian',
      bookingReference: bookingReference,
      arrivalDateTime: DateTime.now(),
      pointOfEntry: 'Julius Nyerere International Airport',
      transportReference: 'KQ 762',
      travelHistory: const [
        TravelHistoryEntry(country: 'Tanzania', period: 'Resident'),
        TravelHistoryEntry(country: 'Kenya', period: '12–15 Aug 2026'),
        TravelHistoryEntry(country: 'Uganda', period: '10–12 Aug 2026'),
      ],
      healthScreening: const HealthScreening(
        vaccinationStatus: 'Fully vaccinated',
        reportedSymptoms: [],
        additionalAnswers: {
          'Contact with confirmed cases': 'No',
          'Currently on medication': 'No',
        },
      ),
    );
  }
}