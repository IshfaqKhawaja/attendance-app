/// Teacher employment type enumeration
/// 
/// Defines the different types of teacher employment contracts.
enum TeacherType {
  permanent('PERMANENT', 'Permanent'),
  guest('GUEST', 'Guest'),
  contract('CONTRACT', 'Contract');

  const TeacherType(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Convert string value to TeacherType enum
  static TeacherType fromString(String value) {
    return TeacherType.values.firstWhere(
      (type) => type.value.toUpperCase() == value.toUpperCase(),
      orElse: () => TeacherType.permanent, // Default to permanent
    );
  }

  /// Get all teacher types as string list (useful for dropdowns)
  static List<String> get allValues => TeacherType.values.map((e) => e.value).toList();

  /// Get all display names as string list
  static List<String> get allDisplayNames => TeacherType.values.map((e) => e.displayName).toList();

  @override
  String toString() => value;
}
