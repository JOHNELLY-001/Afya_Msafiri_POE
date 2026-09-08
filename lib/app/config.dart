class AppConfig {
  AppConfig._();

  /// Toggle this to false once DHIS2/AfyaMsafiri API integration is implemented.
  /// Every feature's repository provider reads this flag to decide which
  /// implementation to hand out — mock or real API. This is the ONLY place
  /// you need to touch to start the swap.
  static const bool useMockData = true;
}