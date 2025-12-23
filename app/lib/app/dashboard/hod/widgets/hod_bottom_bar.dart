import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/hod_bottom_bar_controller.dart';

class HODBottomBar extends StatelessWidget {
  HODBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller - it's guaranteed to be initialized by HodDashboard
    final controller = Get.find<HodBottomBarController>();

    return Obx(() => BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.school,
            label: "Programs",
            isSelected: controller.currentIndex.value == 0,
            onTap: () => controller.changeIndex(0),
          ),
          _buildNavItem(
            icon: Icons.people,
            label: "Teachers",
            isSelected: controller.currentIndex.value == 1,
            onTap: () => controller.changeIndex(1),
          ),
        ],
      ),
    ));
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? Get.theme.primaryColor : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
