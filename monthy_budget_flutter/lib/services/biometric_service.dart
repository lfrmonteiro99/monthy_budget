import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static const _key = 'biometric_lock_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device has biometric hardware and at least one enrolled biometric.
  Future<bool> isDeviceSupported() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();
    return canCheck && isSupported;
  }

  /// Whether the user has enabled biometric lock in settings.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Persist the user's biometric lock preference.
  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// Trigger the OS biometric prompt.  Returns true on success.
  Future<bool> authenticate({String reason = 'Please authenticate'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
