import 'package:app/app/constants/network_constants.dart';
import 'package:app/app/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AddSemesterController  extends GetxController{
  final semesterNameController  =   TextEditingController().obs;
  final client = ApiClient();
  // Initialize with null dates with Obx to update UI:
  var startDate = Rx<DateTime?>(null);
  var endDate = Rx<DateTime?>(null);


  void emptyFields() {
    semesterNameController.value.clear();
    startDate.value = null;
    endDate.value = null;
    update();
  }

  Future<bool> addSemester(String progId) async  {
    final semName = semesterNameController.value.text;
    if(semName.isEmpty){
      Get.snackbar('Error', 'Semester Name cannot be empty');
      return false;
    }
    final start = startDate.value?.toIso8601String();
    final end = endDate.value?.toIso8601String();
    if(start == null || end == null){
      Get.snackbar('Error', 'Start Date and End Date cannot be empty');
      return false;
    }
    final res = await client.postJson(Endpoints.addSemester, {
      'sem_name': semName,
      'start_date': start,
      'end_date': end,
      "prog_id" : progId,
    });

    if(res['success'] == true){
      Get.snackbar('Success', 'Semester Added Successfully', duration: Duration(seconds: 1));
      return true;
    } else {
      Get.snackbar('Error', res['message'] ?? 'Failed to add semester', duration: Duration(seconds: 1));
    }
    emptyFields();
    return false;
  }


  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: Colors.white,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Get.theme.primaryColor;
                }
                return null;
              }),
              todayBorder: BorderSide(color: Get.theme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      startDate.value = picked;
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: Colors.white,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Get.theme.primaryColor;
                }
                return null;
              }),
              todayBorder: BorderSide(color: Get.theme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      endDate.value = picked;
    }
  }




  @override
  void onInit() {
    super.onInit();
    emptyFields();
  }
}