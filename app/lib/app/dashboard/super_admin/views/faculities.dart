import 'package:app/app/dashboard/super_admin/widgets/faculty.dart';
import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Facilities extends StatelessWidget {
  Facilities({super.key});
  final LoadingController loadingController = Get.find<LoadingController>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.only(top: 10, left : 5),
        itemCount: loadingController.faculities.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text("Faculities", style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),);
          }
          index -= 1; // Adjust index for header
          final faculty = loadingController.faculities[index];
          return Faculty(factName: faculty.factName, factId: faculty.factId);
        },
      
    );
  }
}