import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_dashboard_controller.dart';
import '../../teacher/views/teacher_dashboard.dart';
import '../../hod/views/hod_dashboard.dart';
import '../../super_admin/views/dashboard.dart';

/// Main Dashboard that routes to the appropriate dashboard based on user role
///
/// This widget acts as a router/dispatcher that determines which specific
/// dashboard to show based on the authenticated user's role and data.
/// On web, only HOD and SUPER_ADMIN are allowed; teachers must use the mobile app.
class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final MainDashboardController controller = Get.put(MainDashboardController());

    return Obx(() {
      // Show loading while determining which dashboard to display
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading Dashboard...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      // Check if teacher is trying to access web
      if (controller.isTeacherOnWeb.value) {
        return _buildTeacherWebBlockedScreen(controller);
      }

      // Route to the appropriate dashboard based on user role
      return _buildDashboard(controller);
    });
  }

  /// Build the blocked screen for teachers on web
  Widget _buildTeacherWebBlockedScreen(MainDashboardController controller) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_android,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 32),
                Text(
                  'Mobile App Required',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Text(
                    'Teachers must use the mobile app to mark attendance and access course features.\n\nThe web portal is available only for HOD and Super Admin roles.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 48),
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.android, color: Colors.white, size: 32),
                          SizedBox(width: 16),
                          Icon(Icons.apple, color: Colors.white, size: 32),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Download the JMI Attendance app from the App Store or Google Play Store',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () => controller.signOut(),
                  icon: Icon(Icons.logout),
                  label: Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF1E88E5),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(MainDashboardController controller) {
    Widget dashboard;

    if (controller.isSuperAdmin) {
      dashboard = Dashboard(); // Super Admin Dashboard
    } else if (controller.isHod) {
      dashboard = const HodDashboard(); // HOD Dashboard
    } else if (controller.isTeacher) {
      dashboard = TeacherDashboard(); // Teacher Dashboard
    } else {
      // Fallback: redirect to sign in if no valid role
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/sign_in');
      });
      return Scaffold(
        body: Center(
          child: Text('Redirecting to sign in...'),
        ),
      );
    }

    // Wrap dashboard with sign-out button overlay
    return Stack(
      children: [
        dashboard,
        // Sign-out button positioned at top-right
        Positioned(
          right: 10,
          child: SafeArea(
            child: _SignOutButton(controller: controller),
          ),
        ),
      ],
    );
  }
}

/// Sign-out button widget
class _SignOutButton extends StatelessWidget {
  final MainDashboardController controller;

  const _SignOutButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showSignOutDialog(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
