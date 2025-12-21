import 'package:app/app/dashboard/teacher/controllers/teacher_dashboard_controller.dart';
import 'package:app/app/dashboard/dean/controllers/dean_dashboard_controller.dart';
import 'package:app/app/dashboard/super_admin/controllers/super_admin_dashboard_controller.dart';
import 'package:app/app/dashboard/super_admin/controllers/department_controller.dart';
import 'package:get/get.dart';

class HodDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Don't create controller here - it's created in the view with permanent: true
    // to persist state across navigations
  }
}

class TeacherDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherDashboardController>(() => TeacherDashboardController());
  }
}

class DeanDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeanDashboardController>(() => DeanDashboardController());
  }
}

class SuperAdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminDashboardController>(() => SuperAdminDashboardController());
    Get.lazyPut<DepartmentController>(() => DepartmentController());
  }
}