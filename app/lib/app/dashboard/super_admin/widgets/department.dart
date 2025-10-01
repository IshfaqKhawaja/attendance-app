

import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/dashboard/super_admin/controllers/department_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Department extends StatelessWidget {
  final String deptName;
  final String deptId;

  Department({super.key, required this.deptName, required this.deptId});
  final DepartmentController departmentController = Get.find<DepartmentController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: () {
          departmentController.navigateToHodDashboard(deptId);
        },
        title: Text(deptName, style: textStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        ),
        subtitle: Text('ID: $deptId', style: textStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),),
      ),
    );
  }
}