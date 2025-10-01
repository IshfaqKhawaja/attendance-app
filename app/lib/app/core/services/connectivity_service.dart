import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'base_service.dart';

/// Enhanced connectivity service for monitoring network status
/// 
/// Features:
/// - Real-time connectivity monitoring
/// - Connection type detection (WiFi, Mobile, Ethernet)
/// - Automatic reconnection handling
/// - Connection quality assessment
/// - Offline mode management
class ConnectivityService extends BaseService {
  static ConnectivityService get to => Get.find();
  
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  var isConnected = false.obs;
  var connectionType = ConnectivityResult.none.obs;
  var connectionQuality = NetworkQuality.unknown.obs;
  
  // Offline queue for failed requests
  final List<OfflineRequest> _offlineQueue = [];
  
  @override
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          Get.log('Connectivity subscription error: $error');
        },
      );
      
      Get.log('ConnectivityService initialized');
    } catch (e) {
      Get.log('Failed to initialize ConnectivityService: $e');
      rethrow;
    }
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    connectionType.value = result;
    isConnected.value = result != ConnectivityResult.none;
    
    if (isConnected.value) {
      _assessConnectionQuality();
      _processOfflineQueue();
    }
    
    Get.log('Connection status: ${result.name}, Connected: ${isConnected.value}');
  }
  
  Future<void> _assessConnectionQuality() async {
    // Simple quality assessment based on connection type
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        connectionQuality.value = NetworkQuality.excellent;
        break;
      case ConnectivityResult.ethernet:
        connectionQuality.value = NetworkQuality.excellent;
        break;
      case ConnectivityResult.mobile:
        connectionQuality.value = NetworkQuality.good;
        break;
      case ConnectivityResult.bluetooth:
        connectionQuality.value = NetworkQuality.poor;
        break;
      case ConnectivityResult.vpn:
        connectionQuality.value = NetworkQuality.good;
        break;
      default:
        connectionQuality.value = NetworkQuality.none;
    }
  }
  
  /// Add request to offline queue for later processing
  void queueOfflineRequest(OfflineRequest request) {
    _offlineQueue.add(request);
    Get.log('Request queued for offline processing: ${request.endpoint}');
  }
  
  /// Process queued offline requests when connection is restored
  Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty) return;
    
    Get.log('Processing ${_offlineQueue.length} offline requests');
    
    final requestsToProcess = List<OfflineRequest>.from(_offlineQueue);
    _offlineQueue.clear();
    
    for (final request in requestsToProcess) {
      try {
        await request.execute();
        Get.log('Offline request processed successfully: ${request.endpoint}');
      } catch (e) {
        Get.log('Failed to process offline request ${request.endpoint}: $e');
        // Re-queue failed requests with retry logic
        if (request.retryCount < 3) {
          request.retryCount++;
          _offlineQueue.add(request);
        }
      }
    }
  }
  
  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    if (!isConnected.value) return false;
    
    try {
      // You can implement a more sophisticated connectivity check here
      // For now, we rely on the connectivity plugin
      return isConnected.value;
    } catch (e) {
      Get.log('Error checking internet connection: $e');
      return false;
    }
  }
  
  /// Get connection type as string
  String get connectionTypeString {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }
  
  /// Get connection quality as string
  String get connectionQualityString {
    switch (connectionQuality.value) {
      case NetworkQuality.excellent:
        return 'Excellent';
      case NetworkQuality.good:
        return 'Good';
      case NetworkQuality.poor:
        return 'Poor';
      case NetworkQuality.none:
        return 'No Connection';
      case NetworkQuality.unknown:
        return 'Unknown';
    }
  }
  
  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _offlineQueue.clear();
    Get.log('ConnectivityService disposed');
    super.onClose();
  }
}

/// Network quality enumeration
enum NetworkQuality { none, poor, good, excellent, unknown }

/// Offline request model for queuing failed network requests
class OfflineRequest {
  final String endpoint;
  final String method;
  final Map<String, dynamic>? data;
  final Map<String, String>? headers;
  final Future<void> Function() execute;
  int retryCount;
  final DateTime createdAt;
  
  OfflineRequest({
    required this.endpoint,
    required this.method,
    required this.execute,
    this.data,
    this.headers,
    this.retryCount = 0,
  }) : createdAt = DateTime.now();
}