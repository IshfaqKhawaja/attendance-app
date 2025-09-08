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

  Map<String, dynamic> toJson() => {
        "prog_id": progId,
        "prog_name": progName,
        "dept_id": deptId,
        "fact_id": factId,
      };

  ProgramModel copyWith({
    String? progId,
    String? progName,
    String? deptId,
    String? factId,
  }) {
    return ProgramModel(
      progId: progId ?? this.progId,
      progName: progName ?? this.progName,
      deptId: deptId ?? this.deptId,
      factId: factId ?? this.factId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgramModel &&
        other.progId == progId &&
        other.progName == progName &&
        other.deptId == deptId &&
        other.factId == factId;
  }

  @override
  int get hashCode => Object.hash(progId, progName, deptId, factId);
}
