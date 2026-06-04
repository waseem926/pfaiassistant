import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isSupported = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if(!isSupported) return true;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your financial data',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            deviceCredentialsRequiredTitle: 'PIN/Pattern required', 
            biometricHint: 'Verify your identity',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      print("Auth Error: $e");
      return false;
    }
  }
}