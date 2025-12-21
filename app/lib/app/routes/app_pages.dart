import 'package:flutter/foundation.dart' show ValueKey;
import 'package:app/app/course/views/course.dart';
import 'package:app/app/course/views/students.dart';
import 'package:app/app/dashboard/teacher/views/teacher_dashboard.dart';
import 'package:app/app/dashboard/dean/views/dean_dashboard.dart';
import 'package:get/get.dart';
// Local Imports
import '../course/views/course_by_semester_id.dart';
import '../dashboard/main/views/main_dashboard.dart';
import '../dashboard/main/bindings/main_dashboard_binding.dart';
import '../signin/bindings/signin_binding.dart';
import '../dashboard/hod/views/hod_dashboard.dart';
import '../dashboard/super_admin/views/dashboard.dart';
import '../dashboard/super_admin/views/departments.dart';
import '../loading/views/loading.dart';
import '../semester/views/semester_dashboard.dart' show SemesterDashboard;
import '../signin/views/sign_in.dart';
import '../register/views/register.dart';
import '../index/views/index.dart';
import '../student/views/add_students.dart';
import '../core/bindings/dashboard_bindings.dart';
import 'app_routes.dart';

class Pages {
  static final routes = [
    GetPage(name: Routes.LOADING, page: () => LoadingScreen()),
    GetPage(
      name: Routes.SIGN_IN, 
      page: () => SignIn(),
      binding: SignInBinding(),
    ),
    GetPage(name: Routes.REGISTER, page: () => RegisterTeacher()),
    GetPage(
      name: Routes.MAIN_DASHBOARD, 
      page: () => const MainDashboard(),
      binding: MainDashboardBinding(),
    ),
    GetPage(
      name: Routes.TEACHER_DASHBOARD, 
      page: () => TeacherDashboard(),
      binding: TeacherDashboardBinding(),
    ),
    GetPage(
      name: Routes.HOD_DASHBOARD,
      page: () => const HodDashboard(),
      binding: HodDashboardBinding(),
    ),
    GetPage(
      name: Routes.HOD_DASHBOARD_WITH_DEPT,
      page: () {
        // Use deptId as key to force widget recreation when department changes
        final deptId = Get.parameters['deptId'] ?? '';
        return HodDashboard(key: ValueKey(deptId));
      },
      binding: HodDashboardBinding(),
    ),
    GetPage(
      name: Routes.DEAN_DASHBOARD,
      page: () => DeanDashboard(),
      binding: DeanDashboardBinding(),
    ),
    GetPage(
      name: Routes.SUPER_ADMIN_DASHBOARD,
      page: () => Dashboard(),
      binding: SuperAdminDashboardBinding(),
    ),
    GetPage(name: Routes.DEPARTMENTS, page: () {
      final args = Get.arguments;
      final factId = args is Map && args.containsKey('factId')
          ? args['factId']
          : (args is List && args.isNotEmpty ? args[0] : args);
      final factName = args is Map && args.containsKey('factName')
          ? args['factName']
          : (args is List && args.length > 1 ? args[1] : null);
      return Departments(factId: factId, factName: factName);
    }),
    GetPage(name: Routes.SEMESTER, page: () => SemesterDashboard()),
    GetPage(name: Routes.COURSEBYSEM, page: () => CourseBySemesterId()),
    GetPage(name: Routes.COURSE, page: () => Course()),
    GetPage(name: Routes.INDEX_PAGE, page: () => IndexPage()),
    GetPage(name: Routes.ADD_STUDENTS, page: () => AddStudents()),
    GetPage(name: Routes.STUDENTS, page: () => Students()),
  ];
}