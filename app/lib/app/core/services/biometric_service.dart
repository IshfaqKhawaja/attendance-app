import 'package:get/get.dart';

import 'base_service.dart';
import '../utils/platform_utils.dart';

// Conditional imports for local_auth (not supported on web)
import 'biometric_service_mobile.dart'
    if (dart.library.html) 'biometric_service_web.dart' as bio_impl;

/// Biometric authentication result model
class BiometricAuthResult {
  final bool success;
  final String? error;
  final BiometricErrorType? errorType;
  final String? biometricType;

  BiometricAuthResult({
    required this.success,
    this.error,
    this.errorType,
    this.biometricType,
  });
}

/// Biometric error types
enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  lockedOut,
  notSupported,
  userCancelled,
  unknown,
}

/// Biometric authentication service
///
/// Features:
/// - Fingerprint authentication (mobile only)
/// - Face ID/Face recognition (mobile only)
/// - PIN/Pattern fallback (mobile only)
/// - Biometric availability detection
/// - Security settings management
/// - Web gracefully degrades (always returns not available)
class BiometricService extends BaseService {
  static BiometricService get to => Get.find();

  bio_impl.BiometricServiceImpl? _impl;
  bool _initialized = false;

  var isAvailable = false.obs;
  var availableBiometrics = <String>[].obs;
  var isEnabled = false.obs;

  @override
  Future<void> initialize() async {
    // Prevent double initialization
    if (_initialized) {
      Get.log('BiometricService already initialized, skipping');
      return;
    }

    try {
      _impl = bio_impl.BiometricServiceImpl();
      await _impl!.initialize();

      isAvailable.value = _impl!.isAvailable;
      availableBiometrics.value = _impl!.availableBiometricNames;
      _initialized = true;

      Get.log('BiometricService initialized (Platform: ${PlatformUtils.platformName}, Available: ${isAvailable.value})');
    } catch (e) {
      Get.log('Failed to initialize BiometricService: $e');
      isAvailable.value = false;
    }
  }

  /// Authenticate using biometric or device credentials
  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    if (!isAvailable.value) {
      return BiometricAuthResult(
        success: false,
        error: 'Biometric authentication not available on this device',
        errorType: BiometricErrorType.notAvailable,
      );
    }

    return await _impl!.authenticate(
      reason: reason,
      useErrorDialogs: useErrorDialogs,
      stickyAuth: stickyAuth,
      biometricOnly: biometricOnly,
    );
  }

  /// Quick authentication for app unlock
  Future<bool> quickAuthenticate() async {
    if (!isEnabled.value || !isAvailable.value) {
      return false;
    }

    final result = await authenticate(
      reason: 'Authenticate to access Attendance App',
      useErrorDialogs: false,
      stickyAuth: false,
    );

    return result.success;
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    if (!isAvailable.value) {
      return false;
    }

    final result = await authenticate(
      reason: 'Authenticate to enable biometric login',
      useErrorDialogs: true,
      stickyAuth: true,
    );

    if (result.success) {
      isEnabled.value = true;
      Get.log('Biometric authentication enabled');
      return true;
    }

    return false;
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    isEnabled.value = false;
    Get.log('Biometric authentication disabled');
  }

  /// Get available biometric types as strings
  List<String> get availableBiometricNames => availableBiometrics;

  /// Get security level description
  String get securityLevelDescription {
    if (!isAvailable.value) {
      return 'No biometric authentication available';
    }
    return _impl?.securityLevelDescription ?? 'No biometric authentication available';
  }
}