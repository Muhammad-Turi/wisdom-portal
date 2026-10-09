class TeacherModel {
  final String id;
  final String userId;

  final String teacherName;
  final String qualifications;

  TeacherModel({
    required this.userId,
    required this.id,
    required this.teacherName,
    required this.qualifications,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "teacherName": teacherName,
      "qualifications": qualifications,
    };
  }

  factory TeacherModel.fromJson(String id, Map<String, dynamic> json) {
    return TeacherModel(
      id: id,
      userId: json["userId"] ?? "",
      teacherName: json["teacherName"] ?? "",
      qualifications: json["qualifications"] ?? "",
    );
  }
}
