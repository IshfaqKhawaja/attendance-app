import 'package:get/get.dart';

import 'biometric_service.dart';

/// Web implementation of biometric authentication
/// Web browsers don't support biometric authentication directly,
/// so this implementation gracefully degrades to "not available"
class BiometricServiceImpl {
  bool get isAvailable => false;

  Future<void> initialize() async {
    Get.log('Biometric authentication not available on web platform');
  }

  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    return BiometricAuthResult(
      success: false,
      error: 'Biometric authentication is not supported on web browsers',
      errorType: BiometricErrorType.notSupported,
    );
  }

  List<String> get availableBiometricNames => [];

  String get securityLevelDescription =>
      'Biometric authentication not available on web';
}