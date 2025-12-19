import 'package:app/app/dashboard/super_admin/views/faculities.dart';
import 'package:app/app/core/services/user_role_service.dart';
import 'package:app/app/core/widgets/dashboard_scaffold.dart';
import 'package:app/app/core/network/api_client.dart';
import 'package:app/app/core/network/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});
  final UserRoleService roleService = Get.find<UserRoleService>();
  final ApiClient _apiClient = ApiClient();

  Future<void> _sendAttendanceSms() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Send Attendance SMS'),
        content: const Text(
          'This will send SMS notifications to all students with their attendance for today.\n\n'
          'Are you sure you want to proceed?'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SMS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    Get.snackbar(
      'Please wait',
      'Sending attendance SMS to all students...',
      colorText: Colors.blue,
      duration: const Duration(seconds: 2),
    );

    try {
      final response = await _apiClient.getJson(Endpoints.sendAttendanceSms);

      if (response['message'] != null) {
        Get.snackbar(
          'Success',
          response['message'] ?? 'SMS notifications sent successfully',
          colorText: Colors.green,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send SMS: $e',
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      headerContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            roleService.getGreetingMessage(),
            style: GoogleFonts.openSans(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'System Administrator',
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      bodyContent: Facilities(),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendAttendanceSms,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.sms),
      ),
    );
  }
}