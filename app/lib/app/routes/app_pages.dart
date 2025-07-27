import 'package:app/app/course/views/course.dart';
import 'package:app/app/dashboard/views/teacher_dashboard.dart';
import 'package:get/get.dart';
// Local Imports
import '../course/views/course_by_semester_id.dart';
import '../dashboard/views/hod_dashboard.dart';
import '../loading/views/loading.dart';
import '../semester/views/semester_dashboard.dart' show SemesterDashboard;
import '../signin/views/sign_in.dart';
import '../add_courses/views/add_courses.dart';
import '../register/views/register.dart';
import '../index/views/index.dart';
import '../student/views/add_students.dart';
import 'app_routes.dart';

class Pages {
  static final routes = [
    GetPage(name: Routes.LOADING, page: () => LoadingScreen()),
    GetPage(name: Routes.SIGN_IN, page: () => SignIn()),
    GetPage(name: Routes.REGISTER, page: () => RegisterTeacher()),
    GetPage(name: Routes.TEACHER_DASHBOARD, page: () => TeacherDashboard()),
    GetPage(name: Routes.HOD_DASHBOARD, page: () => HodDashboard()),
    GetPage(name: Routes.SEMESTER, page: () => SemesterDashboard()),
    GetPage(name: Routes.COURSEBYSEM, page: () => CourseBySemesterId()),
    GetPage(name: Routes.ADD_COURSES, page: () => AddCourses()),
    GetPage(name: Routes.COURSE, page: () => Course()),
    GetPage(name: Routes.INDEX_PAGE, page: () => IndexPage()),
    GetPage(name: Routes.ADD_STUDENTS, page: () => AddStudents()),
  ];
}
