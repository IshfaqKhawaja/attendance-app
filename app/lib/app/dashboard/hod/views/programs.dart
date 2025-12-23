import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/user_role_service.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/hod_dashboard_controller.dart';

class Programs extends StatelessWidget {
  Programs({super.key});
  final HodDashboardController hodDashboardController =
      Get.find<HodDashboardController>();

  // Max width for list items on web
  static const double maxItemWidth = 600;

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
    final userRoleService = Get.find<UserRoleService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Programs",
                style: GoogleFonts.openSans(
                  fontSize: isDesktop ? 24 : 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Only show tip for HOD users (not for Super Admin or Dean)
              if (userRoleService.isHod) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Add teachers first in the Teachers tab before creating courses',
                          style: GoogleFonts.openSans(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              hodDashboardController.loadPrograms();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12),
              child: Obx(() {
                if (hodDashboardController.isLoading.value) {
                  return ListView(children: const [
                    SizedBox(height: 100),
                    Center(child: CircularProgressIndicator()),
                  ]);
                }
                if (hodDashboardController.errorMessage.value.isNotEmpty) {
                  return ListView(children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            hodDashboardController.errorMessage.value,
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }
                final items = hodDashboardController.programs;
                if (items.isEmpty) {
                  return ListView(children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No programs found',
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }

                // Use grid on larger screens
                if (kIsWeb && crossAxisCount > 1) {
                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.0,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final program = items[index];
                      return _buildProgramCard(program);
                    },
                  );
                }

                // Use list on mobile or single column
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final program = items[index];
                    // Constrain width on web even for list view
                    if (kIsWeb) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxItemWidth),
                          child: _buildProgramCard(program),
                        ),
                      );
                    }
                    return _buildProgramCard(program);
                  },
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgramCard(dynamic program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.toNamed(
              Routes.SEMESTER,
              arguments: {
                'prog_id': program.progId,
                'prog_name': program.progName,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Program Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.school,
                      color: Get.theme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Program Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        program.progName,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.tag, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            program.progId,
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
