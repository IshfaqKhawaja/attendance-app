import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Local Imports:::
import '../controllers/hod_dashboard_controller.dart' show HodDashboardController;

class HodDashboard extends StatelessWidget {
  HodDashboard({super.key});
  final HodDashboardController hodDashboardController = Get.put(
    HodDashboardController(),
    permanent: true,
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
                  "Welcome HOD of\n${hodDashboardController.singInController.userData.value.userName}",
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
                  hodDashboardController.singInController.teacherData.value.teacherId,
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
           
          ],
        ),
             );
    });
  }
}
