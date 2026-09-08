class AuthController {
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Temporary mock authentication.
    //
    // This will later call the AfyaMsafiri authentication API.

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    return true;
  }
}