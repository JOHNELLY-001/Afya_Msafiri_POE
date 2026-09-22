import 'dart:convert';

enum ScanStatus { valid, invalid, expired, alreadyProcessed }

/// Exactly what the real AfyaMsafiri QR code decodes to.
/// Confirmed from a real generated QR:
/// {"bookingID":"...","arrivalDate":"...","portOfEntry":"<org unit uid>"}
class ScanPayload {
  final String bookingId;
  final DateTime arrivalDate;
  final String portOfEntryUid;

  const ScanPayload({
    required this.bookingId,
    required this.arrivalDate,
    required this.portOfEntryUid,
  });

  static ScanPayload? tryParse(String rawCode) {
    try {
      final json = jsonDecode(rawCode) as Map<String, dynamic>;
      final id = json['bookingID'] as String?;
      final arrival = json['arrivalDate'] as String?;
      final poe = json['portOfEntry'] as String?;
      if (id == null || arrival == null || poe == null) return null;
      return ScanPayload(
        bookingId: id,
        arrivalDate: DateTime.parse(arrival),
        portOfEntryUid: poe,
      );
    } catch (_) {
      return null;
    }
  }
}

class ScanResult {
  final ScanStatus status;
  final String bookingReference;
  final ScanPayload? payload;

  const ScanResult({
    required this.status,
    required this.bookingReference,
    this.payload,
  });
}