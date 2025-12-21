/// User role enumeration for type-safe role management
///
/// This enum defines all possible user roles in the system.
/// Using an enum provides compile-time safety and prevents typos in role strings.
///
/// Role Hierarchy:
/// - SUPER_ADMIN: Full system access (view-only mode)
/// - DEAN: Faculty-level access (view-only, can view all departments in their faculty)
/// - HOD: Department-level access (can manage their department - CRUD operations)
/// - TEACHER: Course-level access (can mark attendance for their courses)
enum UserRole {
  superAdmin('SUPER_ADMIN', 'Super Admin'),
  dean('DEAN', 'Dean'),
  hod('HOD', 'Head of Department'),
  teacher('TEACHER', 'Teacher');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Convert string value to UserRole enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value.toUpperCase() == value.toUpperCase(),
      orElse: () => UserRole.teacher, // Default to teacher if unknown
    );
  }

  /// Check if role is super admin
  bool get isSuperAdmin => this == UserRole.superAdmin;

  /// Check if role is Dean
  bool get isDean => this == UserRole.dean;

  /// Check if role is HOD
  bool get isHod => this == UserRole.hod;

  /// Check if role is teacher
  bool get isTeacher => this == UserRole.teacher;

  /// Check if role has admin privileges (super admin, dean, or HOD)
  bool get hasAdminPrivileges => isSuperAdmin || isDean || isHod;

  /// Check if role can perform CRUD operations
  /// Only HOD can perform CRUD, super admin and dean are view-only
  bool get canPerformCrud => isHod;

  /// Check if role is view-only
  bool get isViewOnly => isSuperAdmin || isDean; // Super admin and Dean are view-only

  /// Check if role has faculty-level access (can see all departments in a faculty)
  bool get hasFacultyAccess => isSuperAdmin || isDean;

  @override
  String toString() => value;
}
