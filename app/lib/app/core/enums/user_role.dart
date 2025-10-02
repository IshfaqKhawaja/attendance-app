/// User role enumeration for type-safe role management
/// 
/// This enum defines all possible user roles in the system.
/// Using an enum provides compile-time safety and prevents typos in role strings.
enum UserRole {
  superAdmin('SUPER_ADMIN', 'Super Admin'),
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

  /// Check if role is HOD
  bool get isHod => this == UserRole.hod;

  /// Check if role is teacher
  bool get isTeacher => this == UserRole.teacher;

  /// Check if role has admin privileges (super admin or HOD)
  bool get hasAdminPrivileges => isSuperAdmin || isHod;

  /// Check if role can perform CRUD operations
  bool get canPerformCrud => isHod; // Only HOD can perform CRUD, not super admin

  /// Check if role is view-only
  bool get isViewOnly => isSuperAdmin; // Super admin is view-only

  @override
  String toString() => value;
}
