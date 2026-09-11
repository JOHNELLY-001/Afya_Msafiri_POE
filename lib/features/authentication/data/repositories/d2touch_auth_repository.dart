import 'package:d2_touch/d2_touch.dart';

import '../../../../app/dhis2_config.dart';
import '../../../../shared/models/officer.dart';
import 'package:d2_touch/modules/auth/models/login-response.model.dart';

/// Real DHIS2/AfyaMsafiri implementation, backed by d2_touch's AuthModule.
/// Takes the already-initialized D2Touch singleton, not a freshly
/// constructed one.
class D2TouchAuthRepository {
  D2TouchAuthRepository(this._d2touch);

  final D2Touch _d2touch;

  Future<Officer?> login({
    required String username,
    required String password,
  }) async {
    final status = await _d2touch.authModule.logIn(
      username: username,
      password: password,
      url: Dhis2Config.baseUrl,
    );

    switch (status) {
      case LoginResponseStatus.ONLINE_LOGIN_SUCCESS:
      case LoginResponseStatus.OFFLINE_LOGIN_SUCCESS:
        return const Officer(
          name: 'DHIS2 Officer', // still a placeholder — see note below
          role: 'Health Screening Officer',
        );
      case LoginResponseStatus.WRONG_CREDENTIALS:
        return null;
      case LoginResponseStatus.SERVER_ERROR:
        throw Exception('Unable to reach the AfyaMsafiri server. Please try again.');
    }
  }

  Future<bool> isAuthenticated() => _d2touch.authModule.isAuthenticated();

  Future<void> logout() => _d2touch.authModule.logOut();
}