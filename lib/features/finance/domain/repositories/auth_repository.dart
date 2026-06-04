abstract class AuthRepository {
  Future<bool> isUserRegistered();
  Future<bool> loginWithPin(String pin);
  Future<bool> loginWithBiometrics();
}
