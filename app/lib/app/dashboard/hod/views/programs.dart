import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/typography.dart';
import '../../../routes/app_routes.dart';
import '../controllers/hod_dashboard_controller.dart';

class Programs extends StatelessWidget {
  Programs({super.key});
  final HodDashboardController hodDashboardController =
      Get.find<HodDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "Programs",
            style: GoogleFonts.openSans(
              fontSize: 20,
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final program = items[index];
                    return Card(
                      elevation: 2,
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
                        subtitle: Text("Program Code : ${program.progId}"),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}