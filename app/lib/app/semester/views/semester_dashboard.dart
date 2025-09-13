import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/semester/controllers/semester_controller.dart';
import 'package:app/app/semester/views/add_semester.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../routes/app_routes.dart';
class SemesterDashboard extends StatelessWidget {
   SemesterDashboard({super.key});
  final SemesterController semesterController = Get.put(
    SemesterController(
      progId: Get.arguments['prog_id'] ?? '',
    ),
  );

  @override
  Widget build(BuildContext context) {
    var progId = '';
    var progName =  'Semester Dashboard';
    if (Get.arguments != null) {
      progId = Get.arguments['prog_id'] ?? '';
      progName = Get.arguments['prog_name'] ?? 'Semester Dashboard';
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(progName, style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
        centerTitle: true,
        actions: [
          // Add button to create new semester
          IconButton(
            icon: Icon(Icons.add),
            onPressed: ()  async {
            var added = await showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: AddSemester(
                      progId: progId, 
                    ),);
                },
              );
            print(added);
            if (added != null && added is bool && added) {
                semesterController.getSemestersByProgramId(semesterController.progId);
              }
            
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Get.size.height * 0.8,
              child: Obx(() {
                if (semesterController.semesters.isEmpty) {
                  return Center(child: Text("No semesters found for this program.", style: textStyle.copyWith(fontSize: 18,)));
                }
                return ListView.builder(
                  itemCount: semesterController.semesters.length,
                  itemBuilder: (context, index) {
                    final semester = semesterController.semesters[index];
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        onTap: (){
                          Get.toNamed(Routes.COURSEBYSEM, arguments: {'semesterId': semester.semId, 'semesterName': semester.semName});
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red,),
                          onPressed: () async {
                            final confirmed = await Get.dialog(
                              AlertDialog(
                                title: Text("Confirm Deletion"),
                                content: Text("Are you sure you want to delete this semester?"),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      semesterController.deleteSemester(semester.semId);
                                      Navigator.of( context).pop(true);
                                    },
                                    child: Text("Delete"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text("Cancel"),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              semesterController.deleteSemester(semester.semId);
                            }
                          },
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(semester.semName, style: textStyle.copyWith(fontSize: 16,),),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Start Date: ${DateFormat.yMMMd().format(semester.startDate)}", style: textStyle.copyWith(fontSize: 14,),),
                            Text("End Date: ${DateFormat.yMMMd().format(semester.endDate)}", style: textStyle.copyWith(fontSize: 14,),),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}