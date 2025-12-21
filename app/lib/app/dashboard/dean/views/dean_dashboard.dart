import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/app/core/widgets/dashboard_scaffold.dart';
import 'package:app/app/core/constants/app_colors.dart';
import 'package:app/app/core/utils/responsive_utils.dart';
import '../controllers/dean_dashboard_controller.dart';
import '../widgets/department_card.dart';

class DeanDashboard extends StatelessWidget {
  DeanDashboard({super.key});

  final DeanDashboardController controller = Get.put(DeanDashboardController());

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final crossAxisCount = ResponsiveUtils.value(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 2,
      largeDesktop: 3,
    );

    return DashboardScaffold(
      headerContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => Text(
            'Welcome, ${controller.deanName}',
            style: GoogleFonts.openSans(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 8),
          Obx(() => Text(
            'Dean - ${controller.facultyName}',
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          )),
        ],
      ),
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 24 : 20,
              20,
              isDesktop ? 24 : 20,
              16,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Departments",
                      style: GoogleFonts.openSans(
                        fontSize: isDesktop ? 28 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Obx(() => Text(
                      "${controller.departments.length} departments in your faculty",
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          // Departments Grid/List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.departments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No departments found in your faculty',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Use grid on larger screens for better web appearance
              if (crossAxisCount > 1) {
                return GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: 8,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5, // Wider cards for grid
                  ),
                  itemCount: controller.departments.length,
                  itemBuilder: (context, index) {
                    final department = controller.departments[index];
                    return DeanDepartmentCard(
                      deptName: department.deptName,
                      deptId: department.deptId,
                      index: index,
                      useMargin: false, // No margin in grid layout
                      onTap: () => controller.navigateToHodDashboard(department.deptId),
                    );
                  },
                );
              }

              // Use list on mobile
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.departments.length,
                itemBuilder: (context, index) {
                  final department = controller.departments[index];
                  return DeanDepartmentCard(
                    deptName: department.deptName,
                    deptId: department.deptId,
                    index: index,
                    onTap: () => controller.navigateToHodDashboard(department.deptId),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
