import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'biometric_service.dart';

/// Mobile implementation of biometric authentication using local_auth
class BiometricServiceImpl {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    try {
      _isAvailable = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();

      if (_isAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }

      Get.log('Biometric availability: $_isAvailable');
      Get.log('Available biometrics: ${_availableBiometrics.map((e) => e.name).join(', ')}');
    } catch (e) {
      Get.log('Error checking biometric availability: $e');
      _isAvailable = false;
    }
  }

  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      if (didAuthenticate) {
        Get.log('Biometric authentication successful');
        return BiometricAuthResult(
          success: true,
          biometricType: _getUsedBiometricTypeName(),
        );
      } else {
        Get.log('Biometric authentication failed: User cancelled');
        return BiometricAuthResult(
          success: false,
          error: 'Authentication was cancelled by user',
          errorType: BiometricErrorType.userCancelled,
        );
      }
    } on PlatformException catch (e) {
      Get.log('Biometric authentication error: ${e.code} - ${e.message}');
      return BiometricAuthResult(
        success: false,
        error: e.message ?? 'Authentication failed',
        errorType: _mapPlatformExceptionToErrorType(e.code),
      );
    } catch (e) {
      Get.log('Unexpected biometric authentication error: $e');
      return BiometricAuthResult(
        success: false,
        error: 'An unexpected error occurred',
        errorType: BiometricErrorType.unknown,
      );
    }
  }

  String? _getUsedBiometricTypeName() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return null;
  }

  BiometricErrorType _mapPlatformExceptionToErrorType(String code) {
    switch (code) {
      case 'NotAvailable':
        return BiometricErrorType.notAvailable;
      case 'NotEnrolled':
        return BiometricErrorType.notEnrolled;
      case 'LockedOut':
      case 'PermanentlyLockedOut':
        return BiometricErrorType.lockedOut;
      case 'BiometricOnlyNotSupported':
        return BiometricErrorType.notSupported;
      default:
        return BiometricErrorType.unknown;
    }
  }

  String _getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.weak:
        return 'Device PIN/Pattern';
      case BiometricType.strong:
        return 'Strong Biometric';
    }
  }

  List<String> get availableBiometricNames {
    return _availableBiometrics.map((type) => _getBiometricTypeName(type)).toList();
  }

  String get securityLevelDescription {
    if (_availableBiometrics.contains(BiometricType.face) ||
        _availableBiometrics.contains(BiometricType.iris)) {
      return 'High Security - Face/Iris recognition available';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Good Security - Fingerprint authentication available';
    } else if (_availableBiometrics.contains(BiometricType.weak)) {
      return 'Basic Security - PIN/Pattern authentication available';
    } else {
      return 'No biometric authentication available';
    }
  }
}
