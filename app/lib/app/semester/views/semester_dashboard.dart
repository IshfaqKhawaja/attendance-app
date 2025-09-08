import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/semester/controllers/semester_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../routes/app_routes.dart';
class SemesterDashboard extends StatelessWidget {
   SemesterDashboard({super.key});
  final SemesterController semesterController = Get.put(
    SemesterController(
      programId: Get.arguments['programId'] ?? '',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Semester Dashboard"),
        centerTitle: true,
        actions: [
          // Add button to create new semester
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              
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
                        title: Text(semester.semName, style: textStyle.copyWith(fontSize: 16,),),
                        subtitle: Text("Start Date: ${DateFormat.yMMMd().format(semester.startDate)}", style: textStyle.copyWith(fontSize: 14,),),
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