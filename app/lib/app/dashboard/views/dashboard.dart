import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
// Local Imports:::
import 'package:get/get.dart';
import '../controllers/bottom_bar_controller.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/bottom_bar.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});
  final DashboardController dashboardController = Get.put(
    DashboardController(),
    permanent: true,
  );
  final BottomBarController bottomBarController = Get.put(
    BottomBarController(),
  );

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
                  "What's Up\n${dashboardController.singInController.userData.value.teacherName}",
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
                  dashboardController.singInController.userData.value.teacherId,
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
        bottomNavigationBar: BottomBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: dashboardController.attendanceNotifier,
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
        ),
      );
    });
  }
}
