import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'base_service.dart';

/// Biometric authentication result model
class BiometricAuthResult {
  final bool success;
  final String? error;
  final BiometricErrorType? errorType;
  final BiometricType? biometricType;

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
/// - Fingerprint authentication
/// - Face ID/Face recognition
/// - PIN/Pattern fallback
/// - Biometric availability detection
/// - Security settings management
class BiometricService extends BaseService {
  static BiometricService get to => Get.find();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  var isAvailable = false.obs;
  var availableBiometrics = <BiometricType>[].obs;
  var isEnabled = false.obs;
  
  @override
  Future<void> initialize() async {
    try {
      await _checkBiometricAvailability();
      await _loadBiometricSettings();
      Get.log('BiometricService initialized');
    } catch (e) {
      Get.log('Failed to initialize BiometricService: $e');
      rethrow;
    }
  }
  
  Future<void> _checkBiometricAvailability() async {
    try {
      isAvailable.value = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      
      if (isAvailable.value) {
        availableBiometrics.value = await _localAuth.getAvailableBiometrics();
      }
      
      Get.log('Biometric availability: ${isAvailable.value}');
      Get.log('Available biometrics: ${availableBiometrics.map((e) => e.name).join(', ')}');
    } catch (e) {
      Get.log('Error checking biometric availability: $e');
      isAvailable.value = false;
    }
  }
  
  Future<void> _loadBiometricSettings() async {
    // Load user preference for biometric authentication
    // This would typically come from shared preferences or secure storage
    isEnabled.value = false; // Default to false for security
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
          biometricType: _getUsedBiometricType(),
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
      await _saveBiometricSettings();
      Get.log('Biometric authentication enabled');
      return true;
    }
    
    return false;
  }
  
  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    isEnabled.value = false;
    await _saveBiometricSettings();
    Get.log('Biometric authentication disabled');
  }
  
  Future<void> _saveBiometricSettings() async {
    // Save user preference to secure storage
    // Implementation depends on your storage solution
  }
  
  BiometricType? _getUsedBiometricType() {
    // Return the most secure available biometric type
    if (availableBiometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return BiometricType.iris;
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
  
  /// Get human-readable biometric type names
  String getBiometricTypeName(BiometricType type) {
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
  
  /// Get available biometric types as strings
  List<String> get availableBiometricNames {
    return availableBiometrics.map((type) => getBiometricTypeName(type)).toList();
  }
  
  /// Check if specific biometric type is available
  bool hasBiometricType(BiometricType type) {
    return availableBiometrics.contains(type);
  }
  
  /// Get security level description
  String get securityLevelDescription {
    if (hasBiometricType(BiometricType.face) || hasBiometricType(BiometricType.iris)) {
      return 'High Security - Face/Iris recognition available';
    } else if (hasBiometricType(BiometricType.fingerprint)) {
      return 'Good Security - Fingerprint authentication available';
    } else if (hasBiometricType(BiometricType.weak)) {
      return 'Basic Security - PIN/Pattern authentication available';
    } else {
      return 'No biometric authentication available';
    }
  }
}