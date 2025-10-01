

import 'package:app/app/dashboard/super_admin/controllers/department_controller.dart';
import 'package:app/app/dashboard/super_admin/widgets/department.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Departments extends StatefulWidget {
  final String factId;
  final String factName;
  const Departments({super.key, required this.factId, required this.factName});

  @override
  State<Departments> createState() => _DepartmentsState();
}

class _DepartmentsState extends State<Departments> {
  final DepartmentController departmentController = Get.put(DepartmentController());
  @override
  void initState() {
    super.initState();
    departmentController.loadDepartments(widget.factId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.factName),
        ),
        body: ListView.builder(
          padding: EdgeInsets.only(top: 10, left : 5),
          itemCount: departmentController.departments.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
            return Text("Departments", style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),);
          }
          index -= 1; // Adjust index for header
          final department = departmentController.departments[index];
          return Department(deptName: department.deptName, deptId: department.deptId);
          },
        ),
      );
    });
  }
}