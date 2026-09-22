import 'package:dio/dio.dart';

import '../models/scan_result.dart';
import '../../../../core/network/mediator_client.dart';

class ScanRepository {
  ScanRepository({Dio? dio}) : _dio = dio;
  final Dio? _dio;

  /// Booking-reference validation.
  ///
  /// Real bookingID format from a live AfyaMsafiri QR:
  /// "TSFA" + date + sequence, e.g. TSFA20260914065665.
  /// QR payload is JSON:
  /// `{"bookingID":"...","arrivalDate":"...","portOfEntry":"<uid>"}`.
  ///
  /// When a [Dio] client is injected (live mode), a `TSFA…` id is
  /// verified against the mediator (`arrival → yellowFever →
  /// cardReplacement` bookings): unknown ids become [ScanStatus.invalid].
  /// Network errors fall back to format-only validation so scanning still
  /// works offline.
  Future<ScanResult> validate(String rawCode) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final code = rawCode.trim();
    if (code.isEmpty) {
      return const ScanResult(status: ScanStatus.invalid, bookingReference: '');
    }

    // A real QR is JSON; manual entry may just be the bookingID string.
    final payload = ScanPayload.tryParse(code);
    final bookingId = payload?.bookingId ?? code;

    if (bookingId == 'TSFA-EXPIRED-TEST') {
      return ScanResult(
          status: ScanStatus.expired,
          bookingReference: bookingId,
          payload: payload);
    }
    if (bookingId == 'TSFA-USED-TEST') {
      return ScanResult(
          status: ScanStatus.alreadyProcessed,
          bookingReference: bookingId,
          payload: payload);
    }
    if (!bookingId.startsWith('TSFA')) {
      return ScanResult(
          status: ScanStatus.invalid,
          bookingReference: bookingId,
          payload: payload);
    }

    final dio = _dio;
    if (dio == null) {
      return ScanResult(
          status: ScanStatus.valid,
          bookingReference: bookingId,
          payload: payload);
    }

    // Live existence check across booking types.
    for (final base in [
      '/arrivalBooking',
      '/yellowFeverBooking',
      '/cardReplacementBooking',
    ]) {
      try {
        final response = await dio.get('$base/$bookingId');
        final body = mediatorBody(response);
        if (body != null) {
          return ScanResult(
              status: ScanStatus.valid,
              bookingReference: bookingId,
              payload: payload);
        }
      } on MediatorNotFoundException {
        continue;
      } catch (_) {
        // Network/timeout/server error → format-only fallback (offline).
        return ScanResult(
            status: ScanStatus.valid,
            bookingReference: bookingId,
            payload: payload);
      }
    }
    return ScanResult(
        status: ScanStatus.invalid,
        bookingReference: bookingId,
        payload: payload);
  }
}
