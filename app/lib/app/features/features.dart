// Features barrel exports for better organization
// Authentication
export '../signin/controllers/signin_controller.dart';
export '../signin/controllers/access_controller.dart';
export '../signin/models/user_model.dart';
export '../signin/models/teacher_model.dart';
export '../signin/views/sign_in.dart';
export '../signin/bindings/signin_binding.dart';

// Registration
export '../register/controllers/register_controller.dart';
export '../register/models/register_model.dart';
export '../register/views/register.dart';

// Dashboard
export '../dashboard/main/controllers/main_dashboard_controller.dart';
export '../dashboard/main/views/main_dashboard.dart';
export '../dashboard/main/bindings/main_dashboard_binding.dart';

export '../dashboard/hod/controllers/hod_dashboard_controller.dart';
export '../dashboard/hod/views/hod_dashboard.dart';

export '../dashboard/teacher/controllers/teacher_dashboard_controller.dart';
export '../dashboard/teacher/views/teacher_dashboard.dart';

export '../dashboard/super_admin/controllers/super_admin_dashboard_controller.dart';
export '../dashboard/super_admin/controllers/department_controller.dart';
export '../dashboard/super_admin/views/dashboard.dart';

// Course Management
export '../course/controllers/course_controller.dart';
export '../course/controllers/course_by_sem_id_controller.dart';
export '../course/views/course.dart';

// Semester Management
export '../semester/controllers/semester_controller.dart';
export '../semester/views/semester_dashboard.dart';

// Student Management
export '../student/views/add_students.dart';

// Loading
export '../loading/controllers/loading_controller.dart';
export '../loading/views/loading.dart';