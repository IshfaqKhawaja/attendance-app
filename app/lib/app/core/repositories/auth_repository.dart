import '../network/api_client.dart';
import '../network/endpoints.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  Future<Map<String, dynamic>> sendOtp(String email) async {
    return api.postJson('${Endpoints.baseUrl}/authenticate/send_otp', {
      'email_id': email,
    });
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    return api.postJson('${Endpoints.baseUrl}/authenticate/verify_otp', {
      'email_id': email,
      'otp': otp,
    });
  }
}
