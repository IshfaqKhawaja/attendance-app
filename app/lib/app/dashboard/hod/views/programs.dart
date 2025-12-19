import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/typography.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 10),
          child: Text(
            "Programs",
            style: GoogleFonts.openSans(
              fontSize: isDesktop ? 24 : 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              hodDashboardController.loadPrograms();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 10),
              child: Obx(() {
                if (hodDashboardController.isLoading.value) {
                  return ListView(children: const [
                    SizedBox(height: 16),
                    Center(child: CircularProgressIndicator()),
                  ]);
                }
                if (hodDashboardController.errorMessage.value.isNotEmpty) {
                  return ListView(children: [
                    const SizedBox(height: 16),
                    Center(
                        child:
                            Text(hodDashboardController.errorMessage.value)),
                  ]);
                }
                final items = hodDashboardController.programs;
                if (items.isEmpty) {
                  return ListView(children: const [
                    SizedBox(height: 16),
                    Center(child: Text('No programs found')),
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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          Get.toNamed(
            Routes.SEMESTER,
            arguments: {
              'prog_id': program.progId,
              'prog_name': program.progName,
            },
          );
        },
        title: Text(
          program.progName,
          style: textStyle.copyWith(fontSize: 16),
        ),
        subtitle: Text(
          "Program Code : ${program.progId}",
        ),
        trailing: Tooltip(
          message: 'View Semesters',
          child: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}