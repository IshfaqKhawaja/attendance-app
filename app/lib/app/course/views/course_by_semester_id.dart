import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_by_sem_id_controller.dart';
import '../widgets/add_course.dart';
import 'display_students.dart';

class CourseBySemesterId extends StatefulWidget {
  const CourseBySemesterId({super.key});

  @override
  State<CourseBySemesterId> createState() => _CourseBySemesterIdState();
}

class _CourseBySemesterIdState extends State<CourseBySemesterId> {
  final String semesterId = Get.arguments['semesterId'] ?? '';
  final String semesterName = Get.arguments['semesterName'] ?? 'Courses';

  final CourseBySemesterIdController courseController = Get.put(
    CourseBySemesterIdController(),
  );

  @override
  void initState() {
    super.initState();
    courseController.getCoursesBySemesterId(semesterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( semesterName, style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
        centerTitle: true,
        actions: [
          // Show Student List Button
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text("Student List", style: textStyle.copyWith(fontSize: 18,  fontWeight: FontWeight.bold),),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: DisplayStudents(
                      semId: semesterId,
                    ),
                  ),
                  actions: [

                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
          // Add Student Input Button
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () {
              courseController.selectAndUploadCSVFile(semesterId);
            },
          ),
          // Add button to create new course
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.dialog(
                barrierDismissible: true,
                Dialog(
                  child: AddCourse(
                    semesterId: semesterId,

                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (courseController.coursesBySemesterId.isEmpty) {
          return Center(child:Text("No courses found for this semester.", style: TextStyle(fontSize: 18)));
        }
        return ListView.builder(
          itemCount: courseController.coursesBySemesterId.length,
          itemBuilder: (context, index) {
            final course = courseController.coursesBySemesterId[index];
            return ListTile(
              title: Text(course.courseName, style: textStyle.copyWith(fontSize: 16)),
              // subtitle: Text("Course ID: ${course.courseId}", style: textStyle.copyWith(fontSize: 12)),
              trailing: IntrinsicWidth(
                child: Row(
                  children: [
                    // Generate Report Button
                    ElevatedButton(
                      onPressed: (){
                      courseController.showReportDatePicker(context, course.courseId);
                    }, 
                    child: Text("Generate Report", style: textStyle.copyWith(fontSize: 12,),),),
                    // Edit Button
                    IconButton(onPressed: (){
                    }, icon: Icon(Icons.edit, size: 20, color: Get.theme.colorScheme.primary,)),
                    // Delete Button
                    IconButton(onPressed: (){
                      // Confirm Deletion
                      Get.dialog(
                        AlertDialog(
                          title: Text("Delete Course"),
                          content: Text("Are you sure you want to delete the course '${course.courseName}'? This action cannot be undone."),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                courseController.deleteCourseById(course.courseId, semesterId);
                                Navigator.of(context).pop();
                              },
                              child: Text("Delete", style: TextStyle(color: Colors.red),),
                            ),
                          ],
                        ),
                      );
                    }, icon: Icon(Icons.delete, size: 20, color: Colors.red,)),
                    ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}