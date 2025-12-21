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
  late final HodDashboardController hodDashboardController;
  late final HodBottomBarController hodBottomBarController;

  @override
  void initState() {
    super.initState();
    // Get or create controllers
    hodDashboardController = Get.put(HodDashboardController(), permanent: true);
    hodBottomBarController = Get.put(HodBottomBarController(), permanent: true);

    // Get department ID from route parameters
    final deptId = Get.parameters['deptId'];
    print('HodDashboard initState - deptId from route: $deptId');
    print('HodDashboard initState - old routeDeptId: ${hodDashboardController.routeDeptId}');

    // Set routeDeptId immediately (synchronously) so it's available right away
    hodDashboardController.routeDeptId = deptId;
    print('HodDashboard initState - new routeDeptId: ${hodDashboardController.routeDeptId}');

    // Load data after the frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('HodDashboard postFrameCallback - routeDeptId: ${hodDashboardController.routeDeptId}');
      // Reset to first tab (Programs) when navigating to a new department
      hodBottomBarController.currentIndex.value = 0;
      hodDashboardController.loadPrograms();
      hodBottomBarController.reloadTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleService = Get.find<UserRoleService>();
    return Obx(() {
      return DashboardScaffold(
        showBackButton: roleService.isSuperAdmin || roleService.isDean,
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
            if (roleService.isSuperAdmin || roleService.isDean) ...<Widget>[
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
  