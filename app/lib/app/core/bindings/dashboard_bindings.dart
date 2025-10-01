import 'package:app/app/dashboard/hod/controllers/hod_dashboard_controller.dart';
import 'package:app/app/dashboard/teacher/controllers/teacher_dashboard_controller.dart';
import 'package:app/app/dashboard/super_admin/controllers/super_admin_dashboard_controller.dart';
import 'package:app/app/dashboard/super_admin/controllers/department_controller.dart';
import 'package:get/get.dart';

class HodDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HodDashboardController>(() => HodDashboardController());
  }
}

class TeacherDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherDashboardController>(() => TeacherDashboardController());
  }
}

class SuperAdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminDashboardController>(() => SuperAdminDashboardController());
    Get.lazyPut<DepartmentController>(() => DepartmentController());
  }
}