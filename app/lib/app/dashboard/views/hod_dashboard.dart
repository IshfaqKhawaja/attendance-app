import 'package:app/app/core/constants/typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Local Imports:::
import '../../routes/app_routes.dart';
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
        body: SafeArea(
          child: Stack(
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

            // Get All the Programs of the Department:::
            Positioned(
              top: Get.size.height * 0.26,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                width: Get.size.width,
                child: Text(
                  "Programs",
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: Get.size.height * 0.3,
              child: Container(
                color: Colors.white,
                width: Get.size.width,
                height: Get.size.height * 0.7,
                child: RefreshIndicator(
                  onRefresh: () async {
                    hodDashboardController.loadPrograms();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Builder(
                      builder: (_) {
                        if (hodDashboardController.isLoading.value) {
                          return ListView(children: [
                            SizedBox(height: 16),
                            Center(child: CircularProgressIndicator()),
                          ]);
                        }
                        if ((hodDashboardController.errorMessage?.value ?? '').isNotEmpty) {
                          return ListView(children: [
                            SizedBox(height: 16),
                            Center(child: Text(hodDashboardController.errorMessage!.value)),
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
                                      'programId': program.progId,
                                      'programName': program.progName,
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
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        )),
        );
    }
        );

  }
  }
  