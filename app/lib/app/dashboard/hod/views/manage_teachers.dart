import 'package:app/app/dashboard/hod/widgets/teacher_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/manage_teachers_controller.dart';
import '../widgets/add_teacher_dialog.dart';
import '../../../core/services/user_role_service.dart';

class ManageTeachers extends StatelessWidget {
  ManageTeachers({super.key});
  final ManageTeachersController manageTeachersController = Get.put(
    ManageTeachersController(),
  );

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Teachers",
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
                    await manageTeachersController.loadTeachers();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      itemCount: manageTeachersController.teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = manageTeachersController.teachers[index];
                        return TeacherCard(teacher: teacher);
                      },
                    ),
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
}