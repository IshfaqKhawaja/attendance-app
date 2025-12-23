import 'package:get/get.dart';
import 'package:app/app/constants/network_constants.dart';

import '../../core/network/api_client.dart';
import '../../models/semester_model.dart';
class SemesterController  extends GetxController {
  final String progId;
    final client = ApiClient();


  SemesterController({required this.progId});
  final semesters = <SemesterModel>[].obs;

  void getSemestersByProgramId(String progId) async {
    semesters.clear();
    try {
      final res = await client.getJson(Endpoints.displaySemesterByProgramId(progId));
      if (res["success"] == true) {
        semesters.value = (res["semesters"] as List)
            .map((e) => SemesterModel.fromJson(e))
            .toList()
          ..sort((a, b) => a.semName.toLowerCase().compareTo(b.semName.toLowerCase()));
      } else {
        print('Failed to load semesters: ${res["message"]}');
      }
    } catch (e) {
      print(e.toString());
    }
    
  }


  // Delete Semester
  Future<bool> deleteSemester(String semId) async {
    final res = await client.getJson(Endpoints.deleteSemester(semId));
    if(res['success'] == true){
      Get.snackbar('Success', 'Semester Deleted Successfully', duration: Duration(seconds: 1));
      getSemestersByProgramId(progId);
      return true;
    } else {
      Get.snackbar('Error', res['message'] ?? 'Failed to delete semester', duration: Duration(seconds: 1));
      
    }
    return false;
  }


  @override
  void onInit() {
    super.onInit();
    getSemestersByProgramId(progId);
  }
}