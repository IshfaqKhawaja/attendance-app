import 'package:app/app/course/views/course.dart';
import 'package:app/app/dashboard/views/teacher_dashboard.dart';
import 'package:get/get.dart';
// Local Imports
import '../dashboard/views/hod_dashboard.dart';
import '../loading/views/loading.dart';
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
    GetPage(name: Routes.HOD_DASHBOARD, page: () => HodDashboard()), // Deprecated
    GetPage(name: Routes.ADD_COURSES, page: () => AddCourses()),
    GetPage(name: Routes.COURSE, page: () => Course()),
    GetPage(name: Routes.INDEX_PAGE, page: () => IndexPage()),
    GetPage(name: Routes.ADD_STUDENTS, page: () => AddStudents()),
  ];
}
