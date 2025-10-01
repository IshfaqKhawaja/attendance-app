import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/services.dart';

/// Enhanced controller for handling complex state management patterns
mixin StateMixin<T> on GetxController {
  final Rx<ViewState> _viewState = ViewState.idle.obs;
  final Rx<T?> _data = Rx<T?>(null);
  final RxString _errorMessage = ''.obs;
  
  /// Current view state
  ViewState get viewState => _viewState.value;
  
  /// Current data
  T? get data => _data.value;
  
  /// Current error message
  String get errorMessage => _errorMessage.value;
  
  /// Check if currently loading
  bool get isLoading => viewState == ViewState.loading;
  
  /// Check if has data
  bool get hasData => data != null;
  
  /// Check if has error
  bool get hasError => viewState == ViewState.error;
  
  /// Set loading state
  void setLoading() {
    _viewState.value = ViewState.loading;
    _errorMessage.value = '';
  }
  
  /// Set success state with data
  void setSuccess(T newData) {
    _data.value = newData;
    _viewState.value = ViewState.success;
    _errorMessage.value = '';
  }
  
  /// Set error state with message
  void setError(String error, {bool showToUser = true}) {
    _viewState.value = ViewState.error;
    _errorMessage.value = error;
    
    if (showToUser) {
      ErrorHandlingService.to.logError(error, 
        context: runtimeType.toString(),
        showToUser: true
      );
    }
  }
  
  /// Reset to idle state
  void setIdle() {
    _viewState.value = ViewState.idle;
    _errorMessage.value = '';
  }
  
  /// Execute async operation with automatic state management
  Future<void> executeAsync<R>(
    Future<R> Function() operation, {
    void Function(R result)? onSuccess,
    void Function(String error)? onError,
    bool showErrorToUser = true,
  }) async {
    try {
      setLoading();
      final result = await operation();
      
      if (onSuccess != null) {
        onSuccess(result);
      } else if (result is T) {
        setSuccess(result);
      } else {
        _viewState.value = ViewState.success;
      }
    } catch (e) {
      final errorMsg = e.toString();
      setError(errorMsg, showToUser: showErrorToUser);
      
      if (onError != null) {
        onError(errorMsg);
      }
    }
  }
}

/// Possible view states
enum ViewState {
  idle,
  loading,
  success,
  error,
}

/// Widget builder for different view states
class StateBuilder<T> extends StatelessWidget {
  final GetxController controller;
  final ViewState Function() stateProvider;
  final T? Function() dataProvider;
  final String Function() errorProvider;
  final Widget Function() idleBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(T data) successBuilder;
  final Widget Function(String error) errorBuilder;
  
  const StateBuilder({
    Key? key,
    required this.controller,
    required this.stateProvider,
    required this.dataProvider,
    required this.errorProvider,
    required this.idleBuilder,
    required this.loadingBuilder,
    required this.successBuilder,
    required this.errorBuilder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<GetxController>(
      init: controller,
      builder: (_) {
        switch (stateProvider()) {
          case ViewState.idle:
            return idleBuilder();
          case ViewState.loading:
            return loadingBuilder();
          case ViewState.success:
            final data = dataProvider();
            if (data != null) {
              return successBuilder(data);
            }
            return idleBuilder();
          case ViewState.error:
            return errorBuilder(errorProvider());
        }
      },
    );
  }
}