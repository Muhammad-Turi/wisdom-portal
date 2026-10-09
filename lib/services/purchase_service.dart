import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisdom_portal_1/models/purchase_model.dart';

class PurchaseService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    'purchases',
  );

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user logged in — cannot access data.");
    }
    return user.uid;
  }

  Stream<List<PurchaseModel>> streamPurchases() {
    return _ref.where('userId', isEqualTo: _uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => PurchaseModel.fromJson(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<void> addPurchase(PurchaseModel purchase) async {
    final data = purchase.toJson();
    data['userId'] = _uid;
    await _ref.add(data);
  }

  Future<void> updatePurchase(PurchaseModel purchase) async {
    final data = purchase.toJson();
    data['userId'] = _uid;
    await _ref.doc(purchase.id).update(data);
  }

  Future<void> deletePurchase(String id) async {
    await _ref.doc(id).delete();
  }

  Future<void> deletePurchasesByStudent(String studentId) async {
    final snapshot = await _ref
        .where('userId', isEqualTo: _uid)
        .where('studentId', isEqualTo: studentId)
        .get();

    for (var i = 0; i < snapshot.docs.length; i += 500) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs.skip(i).take(500)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
