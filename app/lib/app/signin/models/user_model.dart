

import '../../core/enums/user_role.dart';

class UserModel {
  final String userId;
  final String userName;
  final String type;
  String? deptId;
  String? factId;
  
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
  
  /// Get user role as enum
  UserRole get role => UserRole.fromString(type);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'type': type,
      'dept_id': deptId,
      'fact_id': factId,
    };
  }

  UserModel copyWith({
    String? userId,
    String? userName,
    String? type,
    String? deptId,
    String? factId,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      deptId: deptId ?? this.deptId,
      factId: factId ?? this.factId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.userId == userId &&
        other.userName == userName &&
        other.type == type &&
        other.deptId == deptId &&
        other.factId == factId;
  }

  @override
  int get hashCode => Object.hash(userId, userName, type, deptId, factId);
}