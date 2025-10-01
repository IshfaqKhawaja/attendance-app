import 'package:get/get.dart';
import '../network/api_client.dart';
import '../../signin/controllers/access_controller.dart';
import 'base_service.dart';

/// Service to manage API interactions
class ApiService extends BaseService {
  static ApiService get to => Get.find<ApiService>();
  
  late ApiClient _client;
  
  /// Get the configured API client
  ApiClient get client => _client;
  
  @override
  Future<void> initialize() async {
    _client = ApiClient(
      tokenProvider: () async {
        // Get token from secure storage via AccessController
        try {
          return await AccessController.getAccessToken();
        } catch (e) {
          return null;
        }
      },
    );
    Get.log('ApiService initialized successfully');
  }
  
  /// Make GET request with error handling
  Future<Map<String, dynamic>> get(String endpoint) async {
    ensureInitialized();
    return await _client.getJson(endpoint);
  }
  
  /// Make POST request with error handling  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    ensureInitialized();
    return await _client.postJson(endpoint, data);
  }
}