import '../controllers/hod_bottom_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Local Imports:::
import '../controllers/hod_dashboard_controller.dart' show HodDashboardController;
import '../widgets/hod_bottom_bar.dart';
import '../../../core/services/user_role_service.dart';
import '../../../core/constants/app_colors.dart';

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
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.1,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Get.find<UserRoleService>().getGreetingMessage(),
                    style: GoogleFonts.openSans(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (Get.find<UserRoleService>().isSuperAdmin) ...<Widget>[
                    SizedBox(height: 8),
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
            ),
          ),
          Positioned(
            top: Get.size.height * 0.25,
            child: Container(
              height: Get.size.height * 0.01,
              width: Get.size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Widget by bottom Bar:
          hodBottomBarController.screens[hodBottomBarController.currentIndex.value],  
        ],
        ),
        bottomNavigationBar: HODBottomBar(),
        );
    }
  );

  }
}
  