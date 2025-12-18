import 'package:app/app/dashboard/hod/widgets/teacher_card.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/manage_teachers_controller.dart';
import '../widgets/add_teacher_dialog.dart';
import '../../../core/services/user_role_service.dart';
import '../../../core/utils/responsive_utils.dart';

class ManageTeachers extends StatelessWidget {
  ManageTeachers({super.key});
  // Controller is pre-registered by HodBottomBarController
  final ManageTeachersController manageTeachersController = Get.find<ManageTeachersController>();

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

    return Obx(() {
      if (manageTeachersController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (manageTeachersController.errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Can't load teachers",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(isDesktop ? 16 : 10),
                child: Text(
                  "Teachers",
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
                    await manageTeachersController.loadTeachers();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 10),
                    child: _buildTeachersList(crossAxisCount),
                  ),
                ),
              ),
            ],
          ),
          // Only show Add button for users with CRUD permissions
          if (Get.find<UserRoleService>().canPerformCrud)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final updated = await showDialog(
                    context: context,
                    builder: (context) {
                      return AddTeacherDialog();
                    },
                  );
                  if (updated == true) {
                    manageTeachersController.loadTeachers();
                  }
                },
                backgroundColor: Get.theme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTeachersList(int crossAxisCount) {
    final teachers = manageTeachersController.teachers;

    if (teachers.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 16),
        Center(child: Text('No teachers found')),
      ]);
    }

    // Use grid on larger screens
    if (kIsWeb && crossAxisCount > 1) {
      return GridView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.8,
        ),
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          return TeacherCard(teacher: teacher);
        },
      );
    }

    // Use list on mobile or single column
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        // Constrain width on web even for list view
        if (kIsWeb) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxItemWidth),
              child: TeacherCard(teacher: teacher),
            ),
          );
        }
        return TeacherCard(teacher: teacher);
      },
    );
  }
}