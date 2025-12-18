import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_by_sem_id_controller.dart';
import '../widgets/add_course.dart';
import '../widgets/edit_course.dart';
import 'display_students.dart';
import '../../core/services/user_role_service.dart';
import '../../core/utils/responsive_utils.dart';

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

  // Max width for list items on web
  static const double maxItemWidth = 600;
  // Max width for dialogs on web
  static const double maxDialogWidth = 400;

  @override
  void initState() {
    super.initState();
    courseController.getCoursesBySemesterId(semesterId);
  }

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text( semesterName, style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
        centerTitle: true,
        actions: [
          // Attendance Report Button
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: (){
              showDialog(context: context, builder: (context) {
               return AlertDialog(
                title: Text("Generate Attendance Report", style: textStyle.copyWith(fontSize: 18,  fontWeight: FontWeight.bold),),
                contentPadding: EdgeInsets.zero,
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
                    minWidth: kIsWeb ? maxDialogWidth : 280,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text("Do you want to generate attendance report for the semester '$semesterName'?", style: textStyle.copyWith(fontSize: 14,),),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back(); // close the dialog
                     courseController.attendanceForSem(semesterId);
                    },
                    child: Text("Generate"),
                  ),
                ],
               );
              });
            },
          ),

          // Show Student List Button (available for all)
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Get.dialog(
                Dialog(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: Get.height * 0.8,
                      maxWidth: kIsWeb ? 500 : Get.width * 0.9,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Student List",
                                style: textStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1),
                        Expanded(
                          child: DisplayStudents(semId: semesterId),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Add Student Input Button (only for CRUD users)
          if (Get.find<UserRoleService>().canPerformCrud)
            IconButton(
              icon: Icon(Icons.upload_file),
              onPressed: () {
                courseController.selectAndUploadCSVFile(semesterId);
              },
            ),
          // Add button to create new course (only for CRUD users)
          if (Get.find<UserRoleService>().canPerformCrud)
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
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 8),
        child: Obx(() {
          if (courseController.coursesBySemesterId.isEmpty) {
            return Center(child:Text("No courses found for this semester.", style: TextStyle(fontSize: 18)));
          }

          // Use grid on larger screens
          if (kIsWeb && crossAxisCount > 1) {
            return GridView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: courseController.coursesBySemesterId.length,
              itemBuilder: (context, index) {
                final course = courseController.coursesBySemesterId[index];
                return _buildCourseCard(context, course);
              },
            );
          }

          // Use list on mobile or single column
          return ListView.builder(
            itemCount: courseController.coursesBySemesterId.length,
            itemBuilder: (context, index) {
              final course = courseController.coursesBySemesterId[index];
              // Constrain width on web even for list view
              if (kIsWeb) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxItemWidth),
                    child: _buildCourseCard(context, course),
                  ),
                );
              }
              return _buildCourseCard(context, course);
            },
          );
        }),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(course.courseName, style: textStyle.copyWith(fontSize: 16)),
        subtitle: Text("Assigned To: ${course.assignedTeacherId}", style: textStyle.copyWith(fontSize: 12)),
        trailing: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Generate Report Button (available for all users)
              ElevatedButton(
                onPressed: (){
                  courseController.showReportDatePicker(context, course.courseId);
                },
                child: Text("Generate Report", style: textStyle.copyWith(fontSize: 12,),),
              ),
              // Edit Button (only for CRUD users)
              if (Get.find<UserRoleService>().canPerformCrud)
                IconButton(onPressed: (){
                  Get.dialog(
                    barrierDismissible: true,
                    Dialog(
                      child: EditCourse(
                        semesterId: semesterId,
                        course: course,
                      ),
                    ),
                  );
                }, icon: Icon(Icons.edit, size: 20, color: Get.theme.colorScheme.primary,)),
              // Delete Button (only for CRUD users)
              if (Get.find<UserRoleService>().canPerformCrud)
                IconButton(onPressed: (){
                  // Confirm Deletion
                  Get.dialog(
                    AlertDialog(
                      title: Text("Delete Course"),
                      contentPadding: EdgeInsets.zero,
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
                          minWidth: kIsWeb ? maxDialogWidth : 280,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text("Are you sure you want to delete the course '${course.courseName}'? This action cannot be undone."),
                        ),
                      ),
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
      ),
    );
  }
}