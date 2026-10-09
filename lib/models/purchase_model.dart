import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  String id;
  final String userId;
  final double amount;
  final String studentId;
  final String itemName;
  final DateTime purchaseDate;
  final String classAtTime;
  bool isPaid;

  PurchaseModel({
    this.id = "",
    required this.userId,
    required this.amount,
    required this.studentId,
    required this.itemName,
    required this.purchaseDate,
    required this.classAtTime,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "amount": amount,
      "studentId": studentId,
      "itemName": itemName,
      "purchaseDate": purchaseDate,
      "classAtTime": classAtTime,
      "isPaid": isPaid,
    };
  }

  factory PurchaseModel.fromJson(String id, Map<String, dynamic> json) {
    return PurchaseModel(
      id: id,
      userId: json["userId"] ?? "",
      amount: (json["amount"] ?? 0).toDouble(),
      studentId: json["studentId"] ?? "",
      itemName: json["itemName"] ?? "",
      purchaseDate:
          (json["purchaseDate"] as Timestamp?)?.toDate() ?? DateTime.now(),
      classAtTime: json["classAtTime"] ?? "",
      isPaid: json["isPaid"] ?? false,
    );
  }
}
