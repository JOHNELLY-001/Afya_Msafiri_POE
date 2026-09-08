import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/point_of_entry/presentation/screens/point_of_entry_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/scanning/presentation/screens/qr_scanner_screen.dart';
import '../features/scanning/presentation/screens/manual_entry_screen.dart';
import '../features/scanning/presentation/screens/invalid_qr_screen.dart';
import '../features/scanning/presentation/screens/already_processed_screen.dart';
import '../features/scanning/presentation/screens/scan_success_screen.dart';
import '../features/traveller/presentation/screens/traveller_record_screen.dart';
import '../features/traveller/presentation/screens/travel_history_screen.dart';
import '../features/traveller/presentation/screens/health_screening_screen.dart';
import '../features/risk_assessment/presentation/screens/risk_assessment_screen.dart';
import '../features/risk_assessment/presentation/screens/risk_details_screen.dart';
import '../features/decisions/presentation/screens/entry_decision_screen.dart';
import '../features/decisions/presentation/screens/confirm_decision_screen.dart';
import '../features/decisions/presentation/screens/decision_recorded_screen.dart';
import '../features/decisions/data/models/decision.dart';
import '../features/synchronization/presentation/screens/sync_center_screen.dart';
import '../features/synchronization/presentation/screens/sync_diagnostics_screen.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const pointOfEntry = '/point-of-entry';
  static const dashboard = '/dashboard';
  static const scan = '/scan';
  static const manualEntry = '/scan/manual-entry';
  static const invalidQr = '/scan/invalid';
  static const alreadyProcessed = '/scan/already-processed';
  static const scanSuccess = '/scan/success';
  static const travellerRecord = '/traveller';
  static const travelHistory = '/traveller/history';
  static const healthScreening = '/traveller/screening';
  static const riskAssessment = '/risk';
  static const riskDetails = '/risk/details';
  static const entryDecision = '/decision';
  static const confirmDecision = '/decision/confirm';
  static const decisionRecorded = '/decision/recorded';
// Step 5 will add: offline, syncCenter, syncDiagnostics
  static const syncCenter = '/sync';
  static const syncDiagnostics = '/sync/diagnostics';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
    GoRoute(path: AppRoutes.pointOfEntry, builder: (context, state) => const PointOfEntryScreen()),
    GoRoute(path: AppRoutes.dashboard, builder: (context, state) => const DashboardScreen()),
    GoRoute(path: AppRoutes.scan, builder: (context, state) => const QrScannerScreen()),
    GoRoute(path: AppRoutes.manualEntry, builder: (context, state) => const ManualEntryScreen()),
    GoRoute(
      path: AppRoutes.invalidQr,
      builder: (context, state) => InvalidQrScreen(reason: state.extra as String?),
    ),
    GoRoute(
      path: AppRoutes.alreadyProcessed,
      builder: (context, state) => AlreadyProcessedScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.scanSuccess,
      builder: (context, state) => ScanSuccessScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.travellerRecord,
      builder: (context, state) => TravellerRecordScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.travelHistory,
      builder: (context, state) => TravelHistoryScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.healthScreening,
      builder: (context, state) => HealthScreeningScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.riskAssessment,
      builder: (context, state) => RiskAssessmentScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.riskDetails,
      builder: (context, state) => RiskDetailsScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.entryDecision,
      builder: (context, state) => EntryDecisionScreen(bookingReference: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: AppRoutes.confirmDecision,
      builder: (context, state) => ConfirmDecisionScreen(draft: state.extra as DecisionDraft),
    ),
    GoRoute(
      path: AppRoutes.decisionRecorded,
      builder: (context, state) => DecisionRecordedScreen(decision: state.extra as Decision),
    ),
    GoRoute(
        path: AppRoutes.syncCenter,
        builder: (context, state) => const SyncCenterScreen()
    ),
    GoRoute(
        path: AppRoutes.syncDiagnostics,
        builder: (context, state) => const SyncDiagnosticsScreen()
    ),
  ],
);