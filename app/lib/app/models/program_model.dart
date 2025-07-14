class ProgramModel {
  final String progId;
  final String progName;
  final String deptId;
  final String factId;

  ProgramModel({
    required this.progId,
    required this.progName,
    required this.deptId,
    required this.factId,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      progId: json["prog_id"],
      progName: json["prog_name"],
      deptId: json["dept_id"],
      factId: json["fact_id"],
    );
  }
}
