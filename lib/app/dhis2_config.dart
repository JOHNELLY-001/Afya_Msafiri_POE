class Dhis2Config {
  Dhis2Config._();

  /// The AfyaMsafiri/DHIS2 instance base URL.
  /// Confirm this with your supervisor/analyst before testing —
  /// this must be a real, reachable DHIS2 instance URL.
  static const String baseUrl = 'https://afyamsafiri-admin.moh.go.tz';

  /// Local SQLite database name d2_touch uses for its own metadata cache.
  /// Separate from our own Drift database (afyamsafiri_manager.sqlite).
  static const String databaseName = 'afyamsafiri_dhis2.db';
}