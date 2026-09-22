import 'package:dio/dio.dart';

import '../../domain/repositories/traveller_repository.dart';
import '../models/traveller.dart';
import '../../../../core/network/mediator_client.dart';
import '../../../scanning/data/models/scan_result.dart';

/// Live mediator implementation.
///
/// Tries the three booking resources in order — arrival, yellowFever,
/// cardReplacement — because a QR `bookingID` can belong to any of them.
/// The mediator answers 400 `"... could not be found"` for unknown ids;
/// that is mapped to [MediatorNotFoundException] by [mediatorBody].
class ApiTravellerRepository implements TravellerRepository {
  ApiTravellerRepository(this._dio);
  final Dio _dio;

  static const _paths = [
    '/arrivalBooking',
    '/yellowFeverBooking',
    '/cardReplacementBooking',
  ];

  @override
  Future<Traveller> fetchByBookingReference(String bookingReference) async {
    final id = bookingReference.trim();
    MediatorNotFoundException? notFound;
    for (final base in _paths) {
      try {
        final response = await _dio.get('$base/$id');
        final body = mediatorBody(response);
        if (body is! Map<String, dynamic>) {
          throw Exception('Unexpected booking response shape');
        }
        return Traveller.fromMediatorJson(
          body,
          fallbackBookingReference: id,
        );
      } on MediatorNotFoundException catch (e) {
        notFound = e;
        continue;
      }
    }
    throw notFound ??
        const MediatorNotFoundException('Booking could not be found');
  }

  /// Lightweight existence check used by the scanner: true when any of
  /// the three booking resources returns 2xx for [bookingId].
  Future<bool> existsBooking(String bookingId) async {
    try {
      await fetchByBookingReference(bookingId);
      return true;
    } on MediatorNotFoundException {
      return false;
    }
  }

  /// Fetch with QR payload context so arrival date / PoE uid survive
  /// even when the booking body omits them.
  Future<Traveller> fetchWithPayload(ScanPayload payload) async {
    try {
      final t = await fetchByBookingReference(payload.bookingId);
      return t;
    } on MediatorNotFoundException {
      rethrow;
    } catch (_) {
      // Fall through to payload-only traveller below.
    }
    return Traveller.fromMediatorJson(
      const {},
      fallbackBookingReference: payload.bookingId,
      fallbackArrival: payload.arrivalDate,
      fallbackPoeUid: payload.portOfEntryUid,
    );
  }
}
