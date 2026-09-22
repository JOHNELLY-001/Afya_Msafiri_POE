import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:d2_touch/d2_touch.dart';
import 'package:d2_touch/modules/auth/models/login-response.model.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/dhis2_config.dart';
import '../../../../shared/models/officer.dart';

/// Result wrapper so [SessionNotifier] can distinguish wrong credentials
/// from network/server/mapping failures and from offline fallback logins.
class D2LoginResult {
  final Officer? officer;
  final bool offline;

  const D2LoginResult._(this.officer, this.offline);

  factory D2LoginResult.online(Officer officer) =>
      D2LoginResult._(officer, false);
  factory D2LoginResult.offline(Officer officer) =>
      D2LoginResult._(officer, true);
  factory D2LoginResult.failed() => const D2LoginResult._(null, false);

  bool get success => officer != null;
}

class D2TouchAuthRepository {
  D2TouchAuthRepository(this._d2touch);

  final D2Touch _d2touch;

  /// Diagnostic client that PRESERVES d2_touch auth.
  ///
  /// d2_touch's HttpClient uses `dioTestClient ?? Dio(BaseOptions(headers:
  /// {Authorization: Basic ...}))`. A bare `Dio()` therefore drops auth and
  /// every login becomes 401. We re-inject the Basic header in onRequest
  /// and only add logging — no mutation of the SDK flow.
  Dio _buildDiagnosticClient({
    required String username,
    required String password,
  }) {
    final dio = Dio();
    final basic = base64Encode(utf8.encode('$username:$password'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.putIfAbsent(
            'Authorization',
            () => 'Basic $basic',
          );
          options.headers.putIfAbsent(
            'Content-Type',
            () => 'application/json',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('========== D2 LOGIN RESPONSE ==========');
          debugPrint('STATUS: ${response.statusCode}');
          debugPrint('URL: ${response.requestOptions.uri}');
          debugPrint('TYPE: ${response.data.runtimeType}');
          debugPrint('DATA: ${response.data}');
          debugPrint('========================================');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('========== D2 LOGIN ERROR =============');
          debugPrint('STATUS: ${error.response?.statusCode}');
          debugPrint('URL: ${error.requestOptions.uri}');
          debugPrint('DATA: ${error.response?.data}');
          debugPrint('MESSAGE: ${error.message}');
          debugPrint('========================================');
          handler.next(error);
        },
      ),
    );
    return dio;
  }

  /// Follows the SDK flow exactly:
  /// `authModule.logIn(username, password, url)` -> GET `{url}/api/me.json`
  /// -> `User.fromApi` -> save user + org units locally.
  Future<D2LoginResult> login({
    required String username,
    required String password,
  }) async {
    LoginResponseStatus status;
    try {
      status = await _d2touch.authModule.logIn(
        username: username,
        password: password,
        url: Dhis2Config.baseUrl,
        dioTestClient: _buildDiagnosticClient(
          username: username,
          password: password,
        ),
      );
    } on TypeError catch (e, stack) {
      // This is the "Null is not a subtype of String" crash: the mediator
      // returned 200 with a body missing id/firstName/name (or double
      // /api/api URL, HTML login page, wrapped envelope, etc.) and
      // User.fromApi blew up inside the SDK.
      debugPrint('D2 LOGIN MAPPING ERROR: $e');
      debugPrint('$stack');
      final offline = await _tryOfflineLogin(
        username: username,
        password: password,
      );
      if (offline != null) return D2LoginResult.offline(offline);
      throw Exception(
        'Login response from the server was not a DHIS2 user '
        '(missing id/name/firstName). Check Dhis2Config.baseUrl and the '
        'mediator /me.json shape. Underlying: $e',
      );
    } catch (e) {
      // Network/Dio/server errors: fall back to cached credentials so
      // officers already seen on this device can still work offline.
      debugPrint('D2 ONLINE LOGIN FAILED, trying offline: $e');
      final offline = await _tryOfflineLogin(
        username: username,
        password: password,
      );
      if (offline != null) return D2LoginResult.offline(offline);
      rethrow;
    }

    switch (status) {
      case LoginResponseStatus.ONLINE_LOGIN_SUCCESS:
      case LoginResponseStatus.OFFLINE_LOGIN_SUCCESS:
        return D2LoginResult.online(await _readCurrentOfficer(
          fallbackUsername: username,
        ));
      case LoginResponseStatus.WRONG_CREDENTIALS:
        return D2LoginResult.failed();
      case LoginResponseStatus.SERVER_ERROR:
        final offline = await _tryOfflineLogin(
          username: username,
          password: password,
        );
        if (offline != null) return D2LoginResult.offline(offline);
        throw Exception(
          'Unable to reach the AfyaMsafiri server. Please try again.',
        );
    }
  }

  /// Offline fallback built on the SDK's own local store (no new flow):
  /// if this device previously logged in, d2_touch kept the User row with
  /// username/password/isLoggedIn. Match them locally.
  Future<Officer?> _tryOfflineLogin({
    required String username,
    required String password,
  }) async {
    try {
      final stored = await _d2touch.userModule.user.getOne();
      if (stored == null) return null;
      if (stored.username != username) return null;
      if (stored.password != password) return null;
      if (!stored.isLoggedIn) return null;
      return _officerFromStored(
        name: stored.name,
        firstName: stored.firstName,
        username: stored.username,
        jobTitle: stored.jobTitle,
      );
    } catch (e) {
      debugPrint('OFFLINE LOGIN CHECK FAILED: $e');
      return null;
    }
  }

  /// Read back the user the SDK just saved, so the UI shows the real
  /// DHIS2 name instead of a hardcoded placeholder.
  Future<Officer> _readCurrentOfficer({required String fallbackUsername}) async {
    try {
      final stored = await _d2touch.userModule.user.getOne();
      if (stored == null) {
        return Officer(
          name: fallbackUsername,
          role: 'Health Screening Officer',
          username: fallbackUsername,
        );
      }
      return _officerFromStored(
        name: stored.name,
        firstName: stored.firstName,
        username: stored.username ?? fallbackUsername,
        jobTitle: stored.jobTitle,
      );
    } catch (_) {
      return Officer(
        name: fallbackUsername,
        role: 'Health Screening Officer',
        username: fallbackUsername,
      );
    }
  }

  Officer _officerFromStored({
    String? name,
    String? firstName,
    String? username,
    String? jobTitle,
  }) {
    final display = (name?.isNotEmpty ?? false)
        ? name!
        : (firstName?.isNotEmpty ?? false)
            ? firstName!
            : (username ?? 'DHIS2 Officer');
    return Officer(
      name: display,
      role: (jobTitle?.isNotEmpty ?? false)
          ? jobTitle!
          : 'Health Screening Officer',
      username: username,
    );
  }

  /// Used by splash restore — pure SDK call, no new logic.
  Future<Officer?> currentOfficer() async {
    final authed = await isAuthenticated();
    if (!authed) return null;
    try {
      final stored = await _d2touch.userModule.user.getOne();
      if (stored == null || !stored.isLoggedIn) return null;
      return _officerFromStored(
        name: stored.name,
        firstName: stored.firstName,
        username: stored.username,
        jobTitle: stored.jobTitle,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() => _d2touch.authModule.isAuthenticated();

  Future<bool> logout() => _d2touch.authModule.logOut();
}
