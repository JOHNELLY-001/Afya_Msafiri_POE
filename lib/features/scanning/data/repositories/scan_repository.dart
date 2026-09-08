import '../models/scan_result.dart';

class ScanRepository {
  /// Mock booking-reference validation.
  /// Later this becomes a DHIS2/AfyaMsafiri API lookup.
  Future<ScanResult> validate(String rawCode) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final code = rawCode.trim();

    if (code.isEmpty) {
      return const ScanResult(status: ScanStatus.invalid, bookingReference: '');
    }

    if (code == 'AMS-EXPIRED') {
      return ScanResult(status: ScanStatus.expired, bookingReference: code);
    }

    if (code == 'AMS-USED') {
      return ScanResult(status: ScanStatus.alreadyProcessed, bookingReference: code);
    }

    if (code.startsWith('AMS-')) {
      return ScanResult(status: ScanStatus.valid, bookingReference: code);
    }

    return ScanResult(status: ScanStatus.invalid, bookingReference: code);
  }
}