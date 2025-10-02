import 'package:get/get.dart';
import '../enums/user_role.dart';
import '../../signin/controllers/signin_controller.dart';

/// Centralized service for managing user roles and permissions
/// 
/// This service provides a single source of truth for:
/// - Current user role
/// - Role-based permissions
/// - Role-based UI visibility
/// - Role-based feature access
class UserRoleService extends GetxService {
  late final SignInController _signInController;

  @override
  void onInit() {
    super.onInit();
    _signInController = Get.find<SignInController>();
  }

  /// Get current user's role
  UserRole get currentRole {
    final userType = _signInController.userData.value.type;
    if (userType.isEmpty) {
      // Check if it's a teacher
      if (_signInController.teacherData.value.teacherId.isNotEmpty) {
        return UserRole.teacher;
      }
    }
    return UserRole.fromString(userType);
  }

  /// Check if current user is super admin
  bool get isSuperAdmin => currentRole.isSuperAdmin;

  /// Check if current user is HOD
  bool get isHod => currentRole.isHod;

  /// Check if current user is teacher
  bool get isTeacher => currentRole.isTeacher;

  /// Check if current user has admin privileges
  bool get hasAdminPrivileges => currentRole.hasAdminPrivileges;

  /// Check if current user can perform CRUD operations
  bool get canPerformCrud => currentRole.canPerformCrud;

  /// Check if current user is in view-only mode
  bool get isViewOnly => currentRole.isViewOnly;

  /// Get user's display name
  String get userName {
    if (isSuperAdmin || isHod) {
      return _signInController.userData.value.userName;
    } else if (isTeacher) {
      return _signInController.teacherData.value.teacherName;
    }
    return '';
  }

  /// Get user's ID
  String get userId {
    if (isSuperAdmin || isHod) {
      return _signInController.userData.value.userId;
    } else if (isTeacher) {
      return _signInController.teacherData.value.teacherId;
    }
    return '';
  }

  /// Get user's department ID
  String? get userDeptId {
    if (isSuperAdmin || isHod) {
      return _signInController.userData.value.deptId;
    } else if (isTeacher) {
      return _signInController.teacherData.value.deptId;
    }
    return null;
  }

  /// Get user's faculty ID (mainly for super admin)
  String? get userFactId {
    if (isSuperAdmin || isHod) {
      return _signInController.userData.value.factId;
    }
    return null;
  }

  /// Check if user can access a specific feature
  bool canAccessFeature(String featureName) {
    switch (featureName) {
      case 'add_teacher':
      case 'edit_teacher':
      case 'delete_teacher':
        return canPerformCrud; // Only HOD can do CRUD operations
      
      case 'view_all_departments':
      case 'view_all_faculties':
        return isSuperAdmin;
      
      case 'mark_attendance':
      case 'view_own_courses':
        return isTeacher;
      
      case 'view_programs':
      case 'view_teachers':
        return hasAdminPrivileges;
      
      default:
        return false;
    }
  }

  /// Get role-specific greeting message
  String getGreetingMessage() {
    final name = userName;
    if (isSuperAdmin) {
      return 'Viewing';  // No 'Admin' suffix for super admin
    } else if (isHod) {
      return 'Welcome\n$name';
    } else if (isTeacher) {
      return 'Hi\n$name';
    }
    return 'Welcome';
  }

  /// Get role display name
  String getRoleDisplayName() {
    return currentRole.displayName;
  }
}
