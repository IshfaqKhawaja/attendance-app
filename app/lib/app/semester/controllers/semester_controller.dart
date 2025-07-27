


import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:app/app/constants/network_constants.dart';

import '../../models/semester_model.dart';
class SemesterController  extends GetxController {
  final String programId;

  SemesterController({required this.programId});
  final semesters = <SemesterModel>[].obs;

  void getSemestersByProgramId(String progId) async {
    try{
      var response = await http.get(Uri.parse("$baseUrl/semester/display_semester_by_program_id/$progId"));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        semesters.value = (data as List)
            .map((s) => SemesterModel.fromJson(s))
            .toList();
      }
    }catch (e) {
      Get.snackbar("Error", "Failed to load semesters: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getSemestersByProgramId(programId);
    
  }
}