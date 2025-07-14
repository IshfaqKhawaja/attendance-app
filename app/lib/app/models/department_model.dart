class DepartmentModel {
  final String deptId;
  final String deptName;
  final String factId;
  DepartmentModel({
    required this.deptId,
    required this.deptName,
    required this.factId,
  });
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      deptId: json['dept_id'] as String,
      deptName: json['dept_name'] as String,
      factId: json["fact_id"] as String,
    );
  }
}
