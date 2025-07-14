import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:get/get.dart';

class TeacherCourseModel {
  final String teacherId;
  final String courseId;
  final String? courseName;
  final String semId;
  final String? semName;
  final String progId;
  final String? progName;
  final String deptId;
  final String? deptName;
  final String factId;
  final String? factName;

  TeacherCourseModel({
    required this.teacherId,
    required this.courseId,
    required this.semId,
    required this.progId,
    required this.deptId,
    required this.factId,
    this.courseName,
    this.deptName,
    this.factName,
    this.progName,
    this.semName,
  });

  factory TeacherCourseModel.fromJson(Map<String, dynamic> json) {
    final LoadingController loadingController = Get.find<LoadingController>();
    final factId = json["fact_id"];
    final faculty = loadingController.faculities
        .where((e) => e.factId == factId)
        .toList()[0];
    final deptId = json["dept_id"];
    final department = loadingController.departments
        .where((e) => e.deptId == deptId)
        .toList()[0];
    final progId = json["prog_id"];
    final program = loadingController.programs
        .where((e) => e.progId == progId)
        .toList()[0];
    final semId = json["sem_id"];
    final semester = loadingController.semesters
        .where((e) => e.semId == semId)
        .toList()[0];
    final courseId = json["course_id"];
    final course = loadingController.courses
        .where((e) => e.courseId == courseId)
        .toList()[0];
    return TeacherCourseModel(
      teacherId: json["teacher_id"],
      courseId: courseId,
      courseName: course.courseName,
      semId: semId,
      semName: semester.semName,
      progId: progId,
      progName: program.progName,
      deptId: deptId,
      deptName: department.deptName,
      factId: factId,
      factName: faculty.factName,
    );
  }
}
