import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/semester/controllers/semester_controller.dart';
import 'package:app/app/semester/views/add_semester.dart';
import 'package:app/app/semester/widgets/delete_semester_button.dart';
import 'package:app/app/semester/widgets/edit_semester_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../routes/app_routes.dart';
import '../../core/services/user_role_service.dart';
import '../../core/utils/responsive_utils.dart';
class SemesterDashboard extends StatelessWidget {
   SemesterDashboard({super.key});
  final SemesterController semesterController = Get.put(
    SemesterController(
      progId: Get.arguments['prog_id'] ?? '',
    ),
  );

  // Max width for list items on web
  static const double maxItemWidth = 600;

  @override
  Widget build(BuildContext context) {
    var progId = '';
    var progName =  'Semester Dashboard';
    if (Get.arguments != null) {
      progId = Get.arguments['prog_id'] ?? '';
      progName = Get.arguments['prog_name'] ?? 'Semester Dashboard';
    }
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
          title: Text(progName, style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
        centerTitle: true,
        actions: [
          // Only show Add button for users with CRUD permissions
          if (Get.find<UserRoleService>().canPerformCrud)
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
            if (added != null && added is bool && added) {
                semesterController.getSemestersByProgramId(semesterController.progId);
              }
            
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Expanded(
              child: Obx(() {
                if (semesterController.semesters.isEmpty) {
                  return Center(child: Text("No semesters found for this program.", style: textStyle.copyWith(fontSize: 18,)));
                }

                // Use grid on larger screens
                if (kIsWeb && crossAxisCount > 1) {
                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: semesterController.semesters.length,
                    itemBuilder: (context, index) {
                      final semester = semesterController.semesters[index];
                      return _buildSemesterCard(context, semester);
                    },
                  );
                }

                // Use list on mobile or single column
                return ListView.builder(
                  itemCount: semesterController.semesters.length,
                  itemBuilder: (context, index) {
                    final semester = semesterController.semesters[index];
                    // Constrain width on web even for list view
                    if (kIsWeb) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxItemWidth),
                          child: _buildSemesterCard(context, semester),
                        ),
                      );
                    }
                    return _buildSemesterCard(context, semester);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterCard(BuildContext context, dynamic semester) {
    return Card(
      elevation: 5,
      child: ListTile(
        onTap: (){
          Get.toNamed(Routes.COURSEBYSEM, arguments: {'semesterId': semester.semId, 'semesterName': semester.semName});
        },
        trailing: Get.find<UserRoleService>().isViewOnly
            ? null  // No actions for view-only users
            : IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit Button
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        var updated = await showDialog(context: context, builder: (context) {
                          return Dialog(
                            child: EditSemesterButton(
                              semId: semester.semId,
                              semName: semester.semName,
                              progId: semester.progId,
                              startDate: semester.startDate,
                              endDate: semester.endDate,
                            ),
                          );
                        });
                        if (updated != null && updated is bool && updated) {
                          semesterController.getSemestersByProgramId(semesterController.progId);
                        }
                      },
                    ),
                    // Delete Button
                    DeleteSemesterButton(semId: semester.semId),
                  ],
                ),
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
  }
}