import '../controllers/hod_bottom_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Local Imports:::
import '../controllers/hod_dashboard_controller.dart' show HodDashboardController;
import '../widgets/hod_bottom_bar.dart';

class HodDashboard extends StatelessWidget {
  HodDashboard({super.key});
  final HodDashboardController hodDashboardController = Get.put(
    HodDashboardController(),
    permanent: true,
  );
  final HodBottomBarController hodBottomBarController = Get.put(
    HodBottomBarController(),
  );
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
                "Welcome \n${hodDashboardController.singInController.userData.value.userName}",
                style: GoogleFonts.openSans(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
  