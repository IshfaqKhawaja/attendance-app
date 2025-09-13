



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class EditSemesterController extends GetxController {
  final client = ApiClient();
  final semesterNameController = TextEditingController().obs;
  var startDate = Rx<DateTime?>(null).obs;
  var endDate = Rx<DateTime?>(null).obs;
  var semId = "".obs;
  var progId = "".obs;

  void initializeFields({
    required String semId,
    required String semName,
    required DateTime start,
    required DateTime end,
    required String progId
  }) {
    semesterNameController.value.text = semName;
    startDate.value.value = start;
    endDate.value.value = end;
    this.semId.value = semId;
    this.progId.value = progId;
    update();
  }


  Future<bool> editSemester() async {
    final semName = semesterNameController.value.text;
    final prodId = progId.value;
    if (semName.isEmpty) {
      Get.snackbar('Error', 'Semester Name cannot be empty');
      return false;
    }
    final start = startDate.value.value != null ? startDate.value.value!.toIso8601String() : '';
    final end = endDate.value.value != null ? endDate.value.value!.toIso8601String() : '';
    final res = await client.postJson(Endpoints.editSemester(semId.value), {
      'sem_name': semName,
      'start_date': start,
      'end_date': end,
      "prog_id": prodId,
    });

    if (res['success'] == true) {
      Get.snackbar('Success', 'Semester Edited Successfully', duration: Duration(seconds: 1));
      return true;
    } else {
      Get.snackbar('Error', res['message'] ?? 'Failed to edit semester', duration: Duration(seconds: 1));
    }
    return false;
  }


  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if(picked != null) {
      startDate.value.value = picked;
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if(picked != null) {
      endDate.value.value = picked;
    }
  }
}