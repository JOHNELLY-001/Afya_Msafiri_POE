import '../../../../shared/models/officer.dart';

class AuthRepository {
  /// Mock login. Later this becomes a Dio call to AfyaMsafiri/DHIS2 auth.
  Future<Officer?> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (username.isEmpty || password.isEmpty) return null;

    return const Officer(
      name: 'John Michael',
      role: 'Health Screening Officer',
    );
  }
}