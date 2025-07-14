class FacultyModel {
  final String factId;
  final String factName;

  FacultyModel({required this.factId, required this.factName});

  // build from a JSON map
  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      factId: json['fact_id'] as String,
      factName: json['fact_name'] as String,
    );
  }
}
