class Dhis2Config {
  Dhis2Config._();

  /// The AfyaMsafiri/DHIS2 instance base URL.
  /// IMPORTANT: do NOT include a trailing `/api` — d2_touch appends
  /// `/api/me.json` itself (HttpClient.get does '${baseUrl}/api/$resource').
  /// Including `/api` here produces `/api/api/me.json` and login parsing fails.
  static const String baseUrl = 'https://afyamsafiri.moh.go.tz/test/mediator';

  /// Local SQLite database name d2_touch uses for its own metadata cache.
  /// Separate from our own Drift database (afyamsafiri_manager.sqlite).
  static const String databaseName = 'afyamsafiri_dhis2.db';
}