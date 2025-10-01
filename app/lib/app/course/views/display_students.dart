



import 'package:app/app/course/controllers/course_by_sem_id_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayStudents extends StatefulWidget {
  final String semId;
  const DisplayStudents({super.key, required this.semId});

  @override
  State<DisplayStudents> createState() => _DisplayStudentsState();
}

class _DisplayStudentsState extends State<DisplayStudents> {
  final CourseBySemesterIdController courseController = CourseBySemesterIdController();

  @override
  void initState() {
    super.initState();
    courseController.fetchStudentsInThisSem(widget.semId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return ListView.builder(
        itemCount: courseController.studentsInThisSem.length,
        itemBuilder: (context, index) {
          final student = courseController.studentsInThisSem[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text('S${index + 1}'),
            ),
            title: Text(student.studentName),
            subtitle: Text(student.studentId),
            trailing: IntrinsicWidth(child: Row(
              children: [
                IconButton(onPressed: (){
                  showDialog(context: context, builder: (context) {
                   return AlertDialog(
                    title: Text("Remove Student", style: TextStyle(fontSize: 18,  fontWeight: FontWeight.bold),),
                    content: Text("Are you sure you want to remove '${student.studentName}' from this semester?", style: TextStyle(fontSize: 14,),),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back(); // close the dialog
                         courseController.deleteStudentFromSem(student.studentId, widget.semId);
                        },
                        child: Text("Remove", style: TextStyle(color: Colors.red),),
                      ),
                    ],
                   );
                  });
                }, icon: Icon(Icons.delete, color: Colors.red,))
              ],
            )),
          );
        },
      );
    });
  }
}