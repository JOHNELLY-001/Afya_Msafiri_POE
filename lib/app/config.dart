/// GLOBAL DATA-SOURCE FLAGS — the single place that decides mock vs live.
///
/// [useMockData] = true  → traveller details, risk assessment, decisions
///   and login run on built-in mocks (no server needed). PoE stations,
///   QR validation and flagged-country counts ALWAYS use the live
///   mediator, independent of this flag.
/// [useMockData] = false → traveller + risk switch to their live mediator
///   repositories. Decisions have NO server endpoint yet (see
///   ApiDecisionRepository SERVER CONFIG), so with live mode every
///   decision is kept in the on-device Drift queue for MANUAL sync from
///   the Sync Center until you configure a real endpoint.
///
/// [bypassAuth] = true (TEMPORARY) → the login window is skipped: splash
///   goes straight to duty-station selection and the router guard is
///   disabled. The mediator exposes no login endpoint (bookings, clients,
///   PoE, risk only — verified via its Swagger), so d2_touch
///   `GET /api/me.json` always 404s. Set to false once a real auth
///   endpoint exists, then wire it in D2TouchAuthRepository.
class AppConfig {
  AppConfig._();

  static const bool useMockData = true;

  static const bool bypassAuth = true;
}

// Mediator base (Swagger UI): https://afyamsafiri.moh.go.tz/test/mediator/api
