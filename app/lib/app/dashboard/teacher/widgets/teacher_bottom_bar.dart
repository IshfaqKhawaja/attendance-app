import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/teacher_bottom_bar_controller.dart';

class TeacherBottomBar extends StatelessWidget {
  TeacherBottomBar({super.key});
  final TeacherBottomBarController controller = Get.put(TeacherBottomBarController());

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => controller.changeIndex(0),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, size: 24, color: Get.theme.primaryColor),
                  const SizedBox(height: 2),
                  Text(
                    "My Courses",
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
