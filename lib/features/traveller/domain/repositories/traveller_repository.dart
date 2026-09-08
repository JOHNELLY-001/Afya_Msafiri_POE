import '../../data/models/traveller.dart';

/// Contract for fetching a traveller record. Both the mock and the future
/// DHIS2 API implementation satisfy this interface, so screens never know
/// (or care) which one is active.
abstract class TravellerRepository {
  Future<Traveller> fetchByBookingReference(String bookingReference);
}