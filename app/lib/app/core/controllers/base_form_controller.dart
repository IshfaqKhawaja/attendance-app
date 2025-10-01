import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_controller.dart';

/// Base form controller with form management utilities
/// 
/// Provides:
/// - Form validation
/// - Field management
/// - Auto-disposal of controllers
abstract class BaseFormController extends BaseController {
  final formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = [];
  final Map<String, RxString> _fieldErrors = {};
  
  /// Register a text controller for auto-disposal
  TextEditingController registerController([String? initialText]) {
    final controller = TextEditingController(text: initialText);
    _controllers.add(controller);
    return controller;
  }
  
  /// Register field error observable
  RxString registerFieldError(String fieldName) {
    final error = RxString('');
    _fieldErrors[fieldName] = error;
    return error;
  }
  
  /// Get field error for a specific field
  RxString? getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }
  
  /// Set field error
  void setFieldError(String fieldName, String? error) {
    final fieldError = _fieldErrors[fieldName];
    if (fieldError != null) {
      fieldError.value = error ?? '';
    }
  }
  
  /// Clear all field errors
  void clearFieldErrors() {
    for (final error in _fieldErrors.values) {
      error.value = '';
    }
  }
  
  /// Clear all form fields
  void clearFormFields() {
    for (final controller in _controllers) {
      controller.clear();
    }
    clearFieldErrors();
    clearError();
  }
  
  /// Validate form
  bool validateForm() {
    clearFieldErrors();
    return formKey.currentState?.validate() ?? false;
  }
  
  /// Submit form with validation
  Future<T?> submitForm<T>(
    Future<T> Function() submitFunction, {
    String? successMessage,
    bool validateFirst = true,
  }) async {
    if (validateFirst && !validateForm()) {
      return null;
    }
    
    return handleAsync(
      submitFunction,
      successMessage: successMessage,
    );
  }
  
  @override
  void onClose() {
    // Dispose all registered controllers
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _fieldErrors.clear();
    super.onClose();
  }
}