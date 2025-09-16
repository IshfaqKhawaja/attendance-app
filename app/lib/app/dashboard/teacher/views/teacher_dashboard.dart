import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Local Imports:::
import '../controllers/teacher_bottom_bar_controller.dart';
import '../controllers/teacher_dashboard_controller.dart';
import '../../../constants/text_styles.dart';
import '../widgets/teacher_bottom_bar.dart';

class TeacherDashboard extends StatefulWidget {
  TeacherDashboard({super.key});

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
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Get.theme.primaryColor, Get.theme.primaryColorLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: Get.size.height * 0.1,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Hi\n${teacherDashboardController.singInController.teacherData.value.teacherName}",
                  style: GoogleFonts.openSans(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: Get.size.height * 0.2,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  teacherDashboardController.singInController.teacherData.value.teacherId,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                  ),
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
            Positioned(
              top: Get.size.height * 0.26,
              child: Container(
                height: Get.size.height * 0.62,
                width: Get.size.width,
                decoration: BoxDecoration(color: Colors.white),
                child: bottomBarController
                    .screens[bottomBarController.currentIndex.value],
              ),
            ),

          ],
        ),
        bottomNavigationBar: TeacherBottomBar(),
        floatingActionButton: bottomBarController.currentIndex.value == 0
            ? FloatingActionButton(
                onPressed: teacherDashboardController.attendanceNotifier,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Send SMS",
                      style: textStyle.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      );
    });
  }
}
