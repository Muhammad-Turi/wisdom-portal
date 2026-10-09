class ClassModel {
  String id;
  final String userId;
  final String className;

  ClassModel({this.id = "", required this.className, required this.userId});

  Map<String, dynamic> toJson() {
    return {"userId": userId, "className": className};
  }

  factory ClassModel.fromJson(String id, Map<String, dynamic> json) {
    return ClassModel(
      id: id,
      userId: json["userId"] ?? "",
      className: json["className"] ?? "",
    );
  }
}
