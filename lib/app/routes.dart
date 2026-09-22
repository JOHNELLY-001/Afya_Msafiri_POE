import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/afya_app_bar.dart';

import '../app/config.dart';
import '../shared/providers/session_provider.dart';
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
import '../features/history/presentation/screens/screening_history_screen.dart';
import '../features/history/presentation/screens/history_detail_screen.dart';
import '../features/synchronization/presentation/screens/sync_center_screen.dart';
import '../features/synchronization/presentation/screens/sync_diagnostics_screen.dart';
import 'main_scaffold.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const pointOfEntry = '/point-of-entry';
  static const dashboard = '/dashboard';
  static const scan = '/scan';
  static const history = '/history';
  static const historyDetail = '/history/detail';
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

List<RouteBase> get _appRoutes => [
      GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.pointOfEntry,
          builder: (context, state) => const PointOfEntryScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.scan,
                builder: (context, state) => const QrScannerScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.history,
                builder: (context, state) =>
                    const ScreeningHistoryScreen()),
          ]),
        ],
      ),
      GoRoute(
          path: AppRoutes.manualEntry,
          builder: (context, state) => const ManualEntryScreen()),
      GoRoute(
        path: AppRoutes.invalidQr,
        builder: (context, state) =>
            InvalidQrScreen(reason: state.extra as String?),
      ),
      GoRoute(
        path: AppRoutes.alreadyProcessed,
        builder: (context, state) => AlreadyProcessedScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.scanSuccess,
        builder: (context, state) => ScanSuccessScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.travellerRecord,
        builder: (context, state) => TravellerRecordScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.historyDetail,
        builder: (context, state) => HistoryDetailScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.travelHistory,
        builder: (context, state) => TravelHistoryScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.healthScreening,
        builder: (context, state) => HealthScreeningScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.riskAssessment,
        builder: (context, state) => RiskAssessmentScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.riskDetails,
        builder: (context, state) => RiskDetailsScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.entryDecision,
        builder: (context, state) => EntryDecisionScreen(
            bookingReference: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.confirmDecision,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! DecisionDraft) {
            return _MissingExtraScaffold(
              title: 'Confirm Decision',
              message:
                  'No decision was selected. Go back and choose cleared, referred or quarantined first.',
              fallback: AppRoutes.entryDecision,
              fallbackLabel: 'Back to Entry Decision',
            );
          }
          return ConfirmDecisionScreen(draft: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.decisionRecorded,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Decision) {
            return const _MissingExtraScaffold(
              title: 'Decision Recorded',
              message:
                  'No recorded decision was found. Start again from the scanner.',
              fallback: AppRoutes.scan,
              fallbackLabel: 'Back to Scanner',
            );
          }
          return DecisionRecordedScreen(decision: extra);
        },
      ),
      GoRoute(
          path: AppRoutes.syncCenter,
          builder: (context, state) => const SyncCenterScreen()),
      GoRoute(
          path: AppRoutes.syncDiagnostics,
          builder: (context, state) => const SyncDiagnosticsScreen()),
    ];

/// Lightweight listenable mirroring the session bits the redirect cares
/// about. Lets a SINGLE GoRouter instance re-evaluate guards on session
/// changes without being recreated (recreating resets navigation to `/`,
/// which caused the POE-pick → splash → POE loop).
class _SessionRefresh extends ChangeNotifier {
  bool loggedIn = false;
  bool hasPoe = false;

  void update({required bool loggedIn, required bool hasPoe}) {
    if (this.loggedIn == loggedIn && this.hasPoe == hasPoe) return;
    this.loggedIn = loggedIn;
    this.hasPoe = hasPoe;
    notifyListeners();
  }
}

final _sessionRefresh = _SessionRefresh();
GoRouter? _cachedRouter;

/// Router with auth + duty-station guards.
/// Public routes: splash + login. Everything else requires
/// `sessionProvider.isLoggedIn`; post-login routes additionally require a
/// selected PoE (duty station) except the picker itself.
///
/// The GoRouter instance is created ONCE and reused across session changes;
/// guards re-run via [refreshListenable]. Previously the provider built a new
/// GoRouter on every session change, dropping the navigation stack back to
/// the splash screen right after POE selection.
final routerProvider = Provider<GoRouter>((ref) {
  final loggedIn = ref.watch(sessionProvider.select((s) => s.isLoggedIn));
  final hasPoe =
      ref.watch(sessionProvider.select((s) => s.selectedPoe != null));
  _sessionRefresh.update(loggedIn: loggedIn, hasPoe: hasPoe);

  _cachedRouter ??= GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _sessionRefresh,
    redirect: (context, state) {
      // TEMPORARY: login window bypassed while mediator has no auth.
      if (AppConfig.bypassAuth) return null;
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.splash;
      final isLogin = location == AppRoutes.login;
      final isPoe = location == AppRoutes.pointOfEntry;

      final l = _sessionRefresh.loggedIn;
      final p = _sessionRefresh.hasPoe;

      if (!l && !isSplash && !isLogin) return AppRoutes.login;
      if (l && isLogin) return AppRoutes.pointOfEntry;
      // Enforce duty-station selection before any post-login screen.
      if (l && !p && !isSplash && !isLogin && !isPoe) {
        return AppRoutes.pointOfEntry;
      }
      return null;
    },
    routes: _appRoutes,
  );
  return _cachedRouter!;
});

/// Fallback shown when a route requiring `extra` is opened without it
/// (deep link, hot restart). Keeps the flow connected instead of crashing.
class _MissingExtraScaffold extends StatelessWidget {
  final String title;
  final String message;
  final String fallback;
  final String fallbackLabel;

  const _MissingExtraScaffold({
    required this.title,
    required this.message,
    required this.fallback,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AfyaAppBar(title: title, showSyncStatus: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(fallback),
                child: Text(fallbackLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Kept for backwards compatibility (e.g. tests). Prefer routerProvider.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: _appRoutes,
);
