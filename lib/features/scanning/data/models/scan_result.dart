enum ScanStatus { valid, invalid, expired, alreadyProcessed }

class ScanResult {
  final ScanStatus status;
  final String bookingReference;

  const ScanResult({
    required this.status,
    required this.bookingReference,
  });
}