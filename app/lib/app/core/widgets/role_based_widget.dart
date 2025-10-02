import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_role_service.dart';

/// Widget that shows/hides children based on user role permissions
/// 
/// This widget makes it easy to conditionally render UI elements based on
/// user roles without cluttering the code with permission checks.
/// 
/// Example usage:
/// ```dart
/// RoleBasedWidget(
///   showForRoles: [UserRole.hod],
///   child: ElevatedButton(
///     onPressed: () => addTeacher(),
///     child: Text('Add Teacher'),
///   ),
/// )
/// ```
class RoleBasedWidget extends StatelessWidget {
  final Widget child;
  final List<String>? showForRoles;
  final List<String>? hideForRoles;
  final bool? showIfCanPerformCrud;
  final bool? showIfHasAdminPrivileges;
  final bool? showIfViewOnly;
  final String? requiredFeature;

  const RoleBasedWidget({
    super.key,
    required this.child,
    this.showForRoles,
    this.hideForRoles,
    this.showIfCanPerformCrud,
    this.showIfHasAdminPrivileges,
    this.showIfViewOnly,
    this.requiredFeature,
  });

  @override
  Widget build(BuildContext context) {
    final roleService = Get.find<UserRoleService>();
    
    // Check if widget should be visible
    bool shouldShow = true;

    // Check role-based visibility
    if (showForRoles != null) {
      shouldShow = showForRoles!.contains(roleService.currentRole.value);
    }

    if (hideForRoles != null) {
      shouldShow = shouldShow && !hideForRoles!.contains(roleService.currentRole.value);
    }

    // Check permission-based visibility
    if (showIfCanPerformCrud != null) {
      shouldShow = shouldShow && (roleService.canPerformCrud == showIfCanPerformCrud);
    }

    if (showIfHasAdminPrivileges != null) {
      shouldShow = shouldShow && (roleService.hasAdminPrivileges == showIfHasAdminPrivileges);
    }

    if (showIfViewOnly != null) {
      shouldShow = shouldShow && (roleService.isViewOnly == showIfViewOnly);
    }

    // Check feature-based visibility
    if (requiredFeature != null) {
      shouldShow = shouldShow && roleService.canAccessFeature(requiredFeature!);
    }

    return shouldShow ? child : const SizedBox.shrink();
  }
}

/// Extension on Widget for easier role-based visibility
extension RoleBasedWidgetExtension on Widget {
  /// Show widget only for specific roles
  Widget showForRoles(List<String> roles) {
    return RoleBasedWidget(
      showForRoles: roles,
      child: this,
    );
  }

  /// Hide widget for specific roles
  Widget hideForRoles(List<String> roles) {
    return RoleBasedWidget(
      hideForRoles: roles,
      child: this,
    );
  }

  /// Show widget only if user can perform CRUD
  Widget showIfCanCrud() {
    return RoleBasedWidget(
      showIfCanPerformCrud: true,
      child: this,
    );
  }

  /// Show widget only for view-only users
  Widget showIfViewOnly() {
    return RoleBasedWidget(
      showIfViewOnly: true,
      child: this,
    );
  }

  /// Show widget only if user has admin privileges
  Widget showIfAdmin() {
    return RoleBasedWidget(
      showIfHasAdminPrivileges: true,
      child: this,
    );
  }

  /// Show widget only if user can access specific feature
  Widget showForFeature(String featureName) {
    return RoleBasedWidget(
      requiredFeature: featureName,
      child: this,
    );
  }
}
