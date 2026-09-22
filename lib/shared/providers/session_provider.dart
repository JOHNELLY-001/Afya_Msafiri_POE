import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../app/config.dart';
import '../models/officer.dart';
import '../models/point_of_entry.dart';
import '../../features/authentication/data/repositories/auth_repository.dart';
import '../../features/authentication/data/repositories/d2touch_auth_repository.dart';
import 'd2touch_provider.dart';

class SessionState {
  final bool isLoggedIn;
  final Officer? officer;
  final PointOfEntry? selectedPoe;
  final bool loading;
  final String? error;
  final bool offlineLogin;

  const SessionState({
    this.isLoggedIn = false,
    this.officer,
    this.selectedPoe,
    this.loading = false,
    this.error,
    this.offlineLogin = false,
  });

  SessionState copyWith({
    bool? isLoggedIn,
    Officer? officer,
    PointOfEntry? selectedPoe,
    bool? loading,
    String? error,
    bool? offlineLogin,
  }) {
    return SessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      officer: officer ?? this.officer,
      selectedPoe: selectedPoe ?? this.selectedPoe,
      loading: loading ?? this.loading,
      error: error,
      offlineLogin: offlineLogin ?? this.offlineLogin,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final d2TouchAuthRepositoryProvider = Provider<D2TouchAuthRepository>((ref) {
  final asyncD2 = ref.watch(d2TouchInstanceProvider);
  return asyncD2.when(
    data: (d2touch) => D2TouchAuthRepository(d2touch),
    loading: () => throw StateError('D2Touch not initialized yet'),
    error: (e, _) => throw e,
  );
});

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);

    if (AppConfig.useMockData) {
      final authRepository = ref.read(authRepositoryProvider);
      final officer =
          await authRepository.login(username: username, password: password);
      if (officer == null) {
        state = state.copyWith(
            loading: false, error: 'Please enter your username and password.');
        return false;
      }
      state = state.copyWith(
          isLoggedIn: true, officer: officer, loading: false);
      return true;
    }

    try {
      final d2touch = await ref.read(d2TouchInstanceProvider.future);
      final d2AuthRepository = D2TouchAuthRepository(d2touch);
      final result = await d2AuthRepository.login(
        username: username,
        password: password,
      );
      if (!result.success) {
        state = state.copyWith(
            loading: false, error: 'Incorrect username or password.');
        return false;
      }
      state = state.copyWith(
        isLoggedIn: true,
        officer: result.officer,
        loading: false,
        offlineLogin: result.offline,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      state = state.copyWith(loading: false, error: _friendlyError(e));
      return false;
    }
  }

  /// Called from splash: restores the SDK-persisted session (d2_touch keeps
  /// isLoggedIn in its local user table) without asking for credentials.
  /// When [AppConfig.bypassAuth] is on, grants a dev session immediately.
  Future<bool> restoreSession() async {
    if (AppConfig.bypassAuth) {
      continueWithoutLogin();
      return true;
    }
    try {
      final d2touch = await ref.read(d2TouchInstanceProvider.future);
      final officer =
          await D2TouchAuthRepository(d2touch).currentOfficer();
      if (officer == null) return false;
      state = state.copyWith(
        isLoggedIn: true,
        officer: officer,
        offlineLogin: true,
      );
      return true;
    } catch (e) {
      debugPrint('RESTORE SESSION FAILED: $e');
      return false;
    }
  }

  /// TEMPORARY dev bypass while the mediator has no auth endpoint.
  /// Sets a local officer session without touching d2_touch.
  void continueWithoutLogin() {
    state = state.copyWith(
      isLoggedIn: true,
      officer: const Officer(
        name: 'PoE Officer',
        role: 'Health Screening Officer',
      ),
      loading: false,
      offlineLogin: true,
    );
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    // Strip "Exception: " prefix for UI display.
    return msg.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  void selectPointOfEntry(PointOfEntry poe) {
    state = state.copyWith(selectedPoe: poe);
  }

  Future<void> logout() async {
    if (!AppConfig.useMockData) {
      try {
        final d2touch = await ref.read(d2TouchInstanceProvider.future);
        await D2TouchAuthRepository(d2touch).logout();
      } catch (e) {
        debugPrint('D2 LOGOUT FAILED: $e');
      }
    }
    state = const SessionState();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(() {
  return SessionNotifier();
});
