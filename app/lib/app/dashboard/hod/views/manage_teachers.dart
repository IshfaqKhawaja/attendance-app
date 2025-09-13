


import 'package:app/app/dashboard/hod/widgets/teacher_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/manage_teachers_controller.dart';
import '../widgets/add_teacher_dialog.dart';

class ManageTeachers extends StatelessWidget {
  ManageTeachers({super.key});
  final ManageTeachersController manageTeachersController = Get.put(
    ManageTeachersController(),
  );

  @override
  Widget build(BuildContext context) {
    final width = Get.size.width;
    final height = Get.size.height;
    return Obx((){
      if (manageTeachersController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
     
      return  Stack(
              children: [
                if (manageTeachersController.errorMessage.isNotEmpty)
                  Positioned(
                    top: height * 0.26,
                    child: Container(
                      padding: EdgeInsets.all(20),
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
                  ),
                

                Positioned(
                  top: height * 0.26,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    width: Get.size.width,
                    child: Text(
                      "Teachers",
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
                    await manageTeachersController.loadTeachers();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.builder(
                          padding: EdgeInsets.only(top: 10, bottom: 20),
                          itemCount: manageTeachersController.teachers.length,
                          itemBuilder: (context, index) {
                            final teacher = manageTeachersController.teachers[index];
                            return TeacherCard(teacher: teacher);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
      
            Positioned(
              bottom: height * 0.001,
              right: width * 0.05,
              child: IconButton(
                onPressed: () async {
                  // Show dialog to add teacher
                 final updated =  await showDialog(
                    context: context,
                    builder: (context) {
                      return AddTeacherDialog();
                    },
                  );
                  if (updated == true) {
                    manageTeachersController.loadTeachers();
                  }
                },
                icon: Icon(
                  Icons.add,color: Get.theme.primaryColor,
                  ),
                iconSize: 50,
                ),
              )
             ],
            );
    }
    );
  }
}