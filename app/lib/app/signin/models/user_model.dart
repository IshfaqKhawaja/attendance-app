

class UserModel {
  final String userId;
  final String userName;
  final String type;
  final String? deptId;
  final String? factId;
  UserModel({
    required this.userId,
    required this.userName,
    required this.type,
    this.deptId,
    this.factId,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      userName: json['user_name'],
      type: json['type'],
      deptId: json['dept_id'],
      factId: json['fact_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'type': type,
      'dept_id': deptId,
      'fact_id': factId,
    };
  }
}