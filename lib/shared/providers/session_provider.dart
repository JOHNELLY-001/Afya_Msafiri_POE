import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const SessionState({
    this.isLoggedIn = false,
    this.officer,
    this.selectedPoe,
    this.loading = false,
    this.error,
  });

  SessionState copyWith({
    bool? isLoggedIn,
    Officer? officer,
    PointOfEntry? selectedPoe,
    bool? loading,
    String? error,
  }) {
    return SessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      officer: officer ?? this.officer,
      selectedPoe: selectedPoe ?? this.selectedPoe,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
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
      final officer = await authRepository.login(username: username, password: password);
      if (officer == null) {
        state = state.copyWith(loading: false, error: 'Please enter your username and password.');
        return false;
      }
      state = state.copyWith(isLoggedIn: true, officer: officer, loading: false);
      return true;
    }

    try {
      final d2touch = await ref.read(d2TouchInstanceProvider.future);
      final d2AuthRepository = D2TouchAuthRepository(d2touch);
      final officer = await d2AuthRepository.login(username: username, password: password);
      if (officer == null) {
        state = state.copyWith(loading: false, error: 'Incorrect username or password.');
        return false;
      }
      state = state.copyWith(isLoggedIn: true, officer: officer, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  void selectPointOfEntry(PointOfEntry poe) {
    state = state.copyWith(selectedPoe: poe);
  }

  void logout() {
    state = const SessionState();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(() {
  return SessionNotifier();
});