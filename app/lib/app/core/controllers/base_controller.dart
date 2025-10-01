import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Base controller with common functionality for all controllers
/// 
/// Provides:
/// - Common error handling
/// - Loading state management
/// - Navigation utilities
/// - Form validation helpers
abstract class BaseController extends GetxController {
  // Common observables
  final isLoading = false.obs;
  final errorMessage = RxString('');
  
  /// Show loading state
  void showLoading() => isLoading.value = true;
  
  /// Hide loading state
  void hideLoading() => isLoading.value = false;
  
  /// Set error message
  void setError(String message) {
    errorMessage.value = message;
    if (message.isNotEmpty) {
      showErrorSnackbar(message);
    }
  }
  
  /// Clear error message
  void clearError() => errorMessage.value = '';
  
  /// Show error snackbar
  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      colorText: Colors.red,
      backgroundColor: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  /// Show success snackbar
  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      colorText: Colors.green,
      backgroundColor: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  /// Show info snackbar
  void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      colorText: Colors.blue,
      backgroundColor: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  /// Validate email format
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }
  
  /// Validate required field
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate minimum length
  String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
  
  /// Handle async operations with loading and error handling
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) this.showLoading();
      clearError();
      
      final result = await operation();
      
      if (successMessage != null) {
        showSuccessSnackbar(successMessage);
      }
      
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      if (showLoading) hideLoading();
    }
  }
  
  /// Safe navigation with error handling
  void safeNavigate(String route, {dynamic arguments}) {
    try {
      Get.toNamed(route, arguments: arguments);
    } catch (e) {
      setError('Navigation failed: ${e.toString()}');
    }
  }
  
  /// Safe off all navigation
  void safeNavigateOffAll(String route, {dynamic arguments}) {
    try {
      Get.offAllNamed(route, arguments: arguments);
    } catch (e) {
      setError('Navigation failed: ${e.toString()}');
    }
  }
}