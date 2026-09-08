import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import '../../features/traveller/data/models/traveller.dart';
import '../../features/traveller/data/repositories/api_traveller_repository.dart';
import '../../features/traveller/data/repositories/mock_traveller_repository.dart';
import '../../features/traveller/domain/repositories/traveller_repository.dart';

/// Single point where mock vs. real repository is chosen.
/// Screens only ever depend on TravellerRepository (the interface),
/// never on MockTravellerRepository or ApiTravellerRepository directly.
final travellerRepositoryProvider = Provider<TravellerRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockTravellerRepository();
  }
  return const ApiTravellerRepository();
});

final travellerByReferenceProvider =
FutureProvider.family<Traveller, String>((ref, bookingReference) async {
  final repository = ref.watch(travellerRepositoryProvider);
  return repository.fetchByBookingReference(bookingReference);
});