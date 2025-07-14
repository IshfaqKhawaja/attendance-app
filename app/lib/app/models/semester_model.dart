class SemesterModel {
  final String semId;
  final String semName;
  final DateTime startDate;
  final DateTime endDate;
  final String progId;

  SemesterModel({
    required this.semId,
    required this.semName,
    required this.startDate,
    required this.endDate,
    required this.progId,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semId: json["sem_id"],
      semName: json["sem_name"],
      startDate: DateTime.parse(json["start_date"]),
      endDate: DateTime.parse(json["end_date"]),
      progId: json["prog_id"],
    );
  }
}
