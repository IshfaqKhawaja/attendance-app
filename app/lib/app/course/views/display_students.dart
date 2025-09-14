



import 'package:app/app/course/controllers/course_by_sem_id_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayStudents extends StatefulWidget {
  final String semId;
  DisplayStudents({super.key, required this.semId});

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
                IconButton(onPressed: (){}, icon: Icon(Icons.edit)),
                IconButton(onPressed: (){}, icon: Icon(Icons.delete, color: Colors.red,))
              ],
            )),
          );
        },
      );
    });
  }
}