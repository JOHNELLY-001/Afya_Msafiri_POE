import '../../domain/repositories/traveller_repository.dart';
import '../models/traveller.dart';

/// Real DHIS2/AfyaMsafiri implementation.
///
/// TODO (Step 8 — API integration):
/// 1. Inject a Dio client (constructor parameter).
/// 2. Call the DHIS2 endpoint that looks up a booking by reference.
/// 3. Parse the response into Traveller.fromJson(...).
/// 4. Handle errors (404 = not found, timeout, auth expiry) and rethrow
///    as domain-specific exceptions the UI can show messages for.
///
/// Nothing outside this file needs to change to activate it — flip
/// AppConfig.useMockData to false once this class is implemented.
class ApiTravellerRepository implements TravellerRepository {
  const ApiTravellerRepository();

  @override
  Future<Traveller> fetchByBookingReference(String bookingReference) async {
    throw UnimplementedError(
      'ApiTravellerRepository is not implemented yet. '
          'Set AppConfig.useMockData = true, or implement this method first.',
    );
  }
}