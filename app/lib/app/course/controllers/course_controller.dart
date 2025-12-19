import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/student_model.dart';
import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/services/file_service.dart';
import '../models/student_attendence.dart';

class CourseController extends GetxController {
  CourseController({required this.courseId});
  var studentsInThisCourse = <StudentModel>[].obs;
  var studentsInThisSem = <StudentModel>[].obs;
  final String courseId;
  // Attendence data:::
  var countedAs = 1.obs;
  var attendenceMarked = <StudentAttendanceList>[].obs;

  final ApiClient client = ApiClient();


 Future<void> getStudentsList() async {
    studentsInThisCourse.clear();
    try {
      final res = await client.getJson(Endpoints.getStudentsByCourseId(courseId));
      if (res["success"] == true) {
        studentsInThisCourse.value = (res["students"] as List)
            .map((e) => StudentModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to load students');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e');
    }
  }
  // Attendence :::
  Future<void> getStudentsForAttendence() async  {
    attendenceMarked.value = studentsInThisCourse.map((student) {
      return StudentAttendanceList(
        studentId: student.studentId,
        studentName: student.studentName, 
        courseId: courseId,
        date: DateTime.now(),
        marked: List.generate(countedAs.value, (_) => false),
      );
    }).toList();
  } 


  // Prepare attendance data for submission
  // making list of maps
  List<StudentAttendance> prepareAttendenceData() {
    var list = <StudentAttendance>[];
    for (var attendance in attendenceMarked) {
      for (int i = 0; i < countedAs.value; i++) {
        list.add(StudentAttendance(
          studentId: attendance.studentId,
          studentName: attendance.studentName,
          courseId: attendance.courseId,
          date: attendance.date,
          present: attendance.marked[i],
          slotNumber: countedAs.value > 1 ? (i + 1) : null, // Add slot number only when multiple slots
        ));
      }
    }
    return list;
  }


  // Check if any attendance has been marked
  bool hasAnyAttendanceMarked() {
    for (var attendance in attendenceMarked) {
      for (var marked in attendance.marked) {
        if (marked) return true;
      }
    }
    return false;
  }

  /// Mark all students as present (all slots filled)
  void selectAllPresent() {
    for (var attendance in attendenceMarked) {
      // Ensure the marked list has the right size
      while (attendance.marked.length < countedAs.value) {
        attendance.marked.add(false);
      }
      // Mark all slots as present
      for (int i = 0; i < countedAs.value; i++) {
        attendance.marked[i] = true;
      }
    }
    attendenceMarked.refresh();
  }

  /// Mark all students as absent (all slots empty)
  void deselectAll() {
    for (var attendance in attendenceMarked) {
      for (int i = 0; i < attendance.marked.length; i++) {
        attendance.marked[i] = false;
      }
    }
    attendenceMarked.refresh();
  }

  /// Check if all students are marked as fully present
  bool areAllPresent() {
    if (attendenceMarked.isEmpty) return false;
    for (var attendance in attendenceMarked) {
      final presentCount = attendance.marked.where((m) => m).length;
      if (presentCount < countedAs.value) return false;
    }
    return true;
  }

  void addAttendence() async {
    // Check if there are students to mark attendance for
    if (attendenceMarked.isEmpty) {
      Get.snackbar(
        "No Students",
        "There are no students in this course to mark attendance for.",
        colorText: Colors.orange,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check if any attendance has been marked
    if (!hasAnyAttendanceMarked()) {
      Get.snackbar(
        "No Attendance Marked",
        "Please mark at least one student as present before saving.",
        colorText: Colors.orange,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      var res = await client.postJson(Endpoints.addAttendanceBulk, {
        'attendances': prepareAttendenceData().map((e) => e.toJson()).toList(),
      });
      if (res["success"]) {
        Get.snackbar(
          "Success",
          res["message"] ?? "Attendance saved successfully!",
          colorText: Colors.green,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        // Reset all controllers after successful submission
        clearAttendence();
        // Regenerate fresh attendance list with default countedAs value
        await getStudentsForAttendence();
      } else {
        Get.snackbar(
          "Error",
          res["message"] ?? "Failed to save attendance",
          colorText: Colors.red,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      String errorMessage = "Something went wrong. Please try again.";

      // Parse error message for better user feedback
      String errorString = e.toString().toLowerCase();
      if (errorString.contains("already") || errorString.contains("409")) {
        errorMessage = "Attendance has already been recorded for this course today. You cannot submit again.";
      } else if (errorString.contains("connection") || errorString.contains("network")) {
        errorMessage = "Network error. Please check your internet connection.";
      } else if (errorString.contains("timeout")) {
        errorMessage = "Request timed out. Please try again.";
      }

      Get.snackbar(
        "Error",
        errorMessage,
        colorText: Colors.red,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }



 void showDateRangeDialog(BuildContext context, String courseName) async {
  DateTime? startDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now().subtract(Duration(days: 7)),
    firstDate: DateTime(2022),
    lastDate: DateTime.now(),
    helpText: "Start Date",
  );

  if (startDate == null) return;

  DateTime? endDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: startDate,
    lastDate: DateTime.now(),
    helpText: "End Date",
  );

  if (endDate == null) return;

  // Confirm dialog
  Get.dialog(
    AlertDialog(
      title: Text("Generate Report"),
      content: Text("Do you want to generate report from ${startDate.day}/${startDate.month}/${startDate.year} to ${endDate.day}/${endDate.month}/${endDate.year}?"),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // close the dialog
            generateReport(courseName, startDate, endDate);
          },
          child: Text("Generate", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

  Future<void> generateReport(String courseName, DateTime startDate, DateTime endDate) async {
  try {
    final bytes = await client.postBytes(
      Endpoints.generateAttendanceReport,
      {
        'course_name': courseName,
        'course_id': courseId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    if (bytes.isEmpty) {
      Get.snackbar("No Data", "No attendance records found for the selected date range.",
        colorText: Colors.orange,
      );
      return;
    }

    final fileName = "attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final filePath = await FileService.saveFile(
      bytes: bytes,
      fileName: fileName,
    );

    if (filePath != null) {
      final opened = await FileService.openFile(filePath);
      if (opened) {
        Get.snackbar("Success", "Report opened successfully", colorText: Colors.green);
      } else {
        if (FileService.isSupported) {
          await FileService.shareFile(filePath, text: 'Attendance Report');
        } else {
          Get.snackbar("Success", "Report downloaded successfully", colorText: Colors.green);
        }
      }
    } else {
      Get.snackbar("Error", "Failed to save report", colorText: Colors.red);
    }
  } catch (e) {
    print(e);
    Get.snackbar("Error", "Something went wrong: $e", colorText: Colors.red);
  }
}


void clear() {
  studentsInThisCourse.clear();
  attendenceMarked.clear();
  countedAs.value = 1;
}

void clearAttendence() {
  attendenceMarked.clear();
  countedAs.value = 1;
}

// Student CRUD operations
Future<void> addStudent(String studentId, String studentName, String phoneNumber, String semId) async {
  if (studentId.isEmpty || studentName.isEmpty || phoneNumber.isEmpty) {
    Get.snackbar("Error", "Please fill all fields");
    return;
  }

  try {
    // Parse phone number to int, default to 0 if invalid
    int phoneNumberInt = int.tryParse(phoneNumber) ?? 0;

    // First add the student to the students table (includes sem_id)
    var res = await client.postJson(Endpoints.addStudent, {
      "student_id": studentId,
      "student_name": studentName,
      "phone_number": phoneNumberInt,
      "sem_id": semId,
    });

    if (res["success"] == true) {
      // Then add the student enrollment for this semester
      var enrollRes = await client.postJson(Endpoints.addStudentEnrollment, {
        "student_id": studentId,
        "sem_id": semId,
      });

      if (enrollRes["success"] == true) {
        Get.snackbar("Success", "Student Added Successfully");
        await getStudentsList(); // Refresh the list
        await getStudentsForAttendence(); // Refresh attendance list
      } else {
        Get.snackbar("Error", enrollRes["message"]?.toString() ?? "Failed to enroll student");
      }
    } else {
      // If student already exists, still try to enroll them
      if (res["message"]?.toString().contains("already exists") == true) {
        var enrollRes = await client.postJson(Endpoints.addStudentEnrollment, {
          "student_id": studentId,
          "sem_id": semId,
        });

        if (enrollRes["success"] == true) {
          Get.snackbar("Success", "Student Enrolled Successfully");
          await getStudentsList();
          await getStudentsForAttendence(); // Refresh attendance list
        } else {
          Get.snackbar("Error", enrollRes["message"]?.toString() ?? "Failed to enroll student");
        }
      } else {
        Get.snackbar("Error", res["message"]?.toString() ?? "Failed to add student");
      }
    }
  } catch (e) {
    Get.snackbar("Error", "Failed to add student: $e");
  }
}

Future<void> editStudent(String studentId, String studentName, String phoneNumber, String semId) async {
  if (studentName.isEmpty || phoneNumber.isEmpty) {
    Get.snackbar("Error", "Please fill all fields");
    return;
  }

  try {
    // Parse phone number to int, default to 0 if invalid
    int phoneNumberInt = int.tryParse(phoneNumber) ?? 0;

    var res = await client.postJson(Endpoints.editStudent, {
      "student_id": studentId,
      "student_name": studentName,
      "phone_number": phoneNumberInt,
    });

    if (res["success"] == true) {
      Get.snackbar("Success", "Student Updated Successfully");
      await getStudentsList(); // Refresh the list
      await getStudentsForAttendence(); // Refresh attendance list
    } else {
      Get.snackbar("Error", res["message"]?.toString() ?? "Failed to update student");
    }
  } catch (e) {
    Get.snackbar("Error", "Failed to update student: $e");
  }
}

Future<void> deleteStudentFromCourse(String studentId, String semId) async {
  try {
    var res = await client.postJson(Endpoints.deleteStudentById, {
      "student_id": studentId,
      "sem_id": semId,
    });

    if (res["success"] == true) {
      Get.snackbar("Success", "Student Removed Successfully");
      await getStudentsList(); // Refresh the list
      await getStudentsForAttendence(); // Refresh attendance list
    } else {
      Get.snackbar("Error", res["message"]?.toString() ?? "Failed to remove student");
    }
  } catch (e) {
    Get.snackbar("Error", "Failed to remove student: $e");
  }
}



}