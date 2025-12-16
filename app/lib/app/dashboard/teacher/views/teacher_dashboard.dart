import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Local Imports:::
import '../controllers/teacher_bottom_bar_controller.dart';
import '../controllers/teacher_dashboard_controller.dart';
import '../widgets/teacher_bottom_bar.dart';
import '../../../core/services/user_role_service.dart';
import '../../../core/widgets/dashboard_scaffold.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final TeacherDashboardController teacherDashboardController = Get.put(
    TeacherDashboardController(),
    permanent: true,
  );

  final TeacherBottomBarController bottomBarController = Get.put(
    TeacherBottomBarController(),
  );

  @override
  void initState() {
    super.initState();
    teacherDashboardController.loadTeacherCourses();
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
            const SizedBox(height: 8),
            Text(
              Get.find<UserRoleService>().userId,
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        bodyContent: bottomBarController
            .screens[bottomBarController.currentIndex.value],
        bottomNavigationBar: TeacherBottomBar(),
      );
    });
  }
}
