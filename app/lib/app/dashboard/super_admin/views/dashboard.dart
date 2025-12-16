import 'package:app/app/dashboard/super_admin/views/faculities.dart';
import 'package:app/app/core/services/user_role_service.dart';
import 'package:app/app/core/widgets/dashboard_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});
  final UserRoleService roleService = Get.find<UserRoleService>();

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
    );
  }
}