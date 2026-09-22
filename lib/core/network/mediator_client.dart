import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL of the AfyaMsafiri mediator (NestJS, Swagger at `/api/`).
/// NOTE: this is NOT a DHIS2 instance — it has no `/api/me.json` and no
/// login endpoint. d2_touch auth must NOT point here. Usable resources:
/// poeCenters, riskcountries, arrival/yellowFever/cardReplacement bookings,
/// client, certificates, booking-form metadata.
class MediatorConfig {
  MediatorConfig._();
  static const String baseUrl =
      'https://afyamsafiri.moh.go.tz/test/mediator/api';
}

/// Thrown when the mediator reports a booking/client/certificate
/// identifier "could not be found" (HTTP 400 with that message).
class MediatorNotFoundException implements Exception {
  final String message;
  const MediatorNotFoundException(this.message);
  @override
  String toString() => message;
}

final mediatorClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: MediatorConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
      // The mediator uses 400 for "not found" (not 404), so don't let
      // Dio throw before we can map the body ourselves.
      validateStatus: (status) => status != null && status < 500,
    ),
  );
  return dio;
});

/// Returns the decoded body for 2xx, throws [MediatorNotFoundException]
/// for "could not be found" 400s, otherwise throws the mediator message.
dynamic mediatorBody(Response response) {
  final code = response.statusCode ?? 500;
  final data = response.data;
  if (code >= 200 && code < 300) return data;
  final msg = data is Map
      ? (data['message'] ?? data['error'] ?? 'Request failed ($code)')
          .toString()
      : 'Request failed ($code)';
  if (msg.contains('could not be found')) {
    throw MediatorNotFoundException(msg);
  }
  throw Exception(msg);
}
