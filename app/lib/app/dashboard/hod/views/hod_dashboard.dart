import '../controllers/hod_bottom_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Local Imports:::
import '../controllers/hod_dashboard_controller.dart' show HodDashboardController;
import '../widgets/hod_bottom_bar.dart';
import '../../../core/services/user_role_service.dart';
import '../../../core/widgets/dashboard_scaffold.dart';

class HodDashboard extends StatefulWidget {
  const HodDashboard({super.key});

  @override
  State<HodDashboard> createState() => _HodDashboardState();
}

class _HodDashboardState extends State<HodDashboard> {
  final HodDashboardController hodDashboardController = Get.put(
    HodDashboardController(),
    permanent: true,
  );

  final HodBottomBarController hodBottomBarController = Get.put(
    HodBottomBarController(),
  );

  String? deptId;

  @override
  void initState() {
    super.initState();
    deptId = Get.parameters['deptId'];
    hodDashboardController.init(deptId: deptId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DashboardScaffold(
        headerContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Get.find<UserRoleService>().getGreetingMessage(),
              style: GoogleFonts.openSans(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (Get.find<UserRoleService>().isSuperAdmin) ...<Widget>[
              const SizedBox(height: 8),
              if (hodDashboardController.departmentName != null)
                Text(
                  "Department: ${hodDashboardController.departmentName}",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (hodDashboardController.facultyName != null)
                Text(
                  "Faculty: ${hodDashboardController.facultyName}",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ],
        ),
        bodyContent:
            hodBottomBarController.screens[hodBottomBarController.currentIndex.value],
        bottomNavigationBar: HODBottomBar(),
      );
    });
  }
}
  