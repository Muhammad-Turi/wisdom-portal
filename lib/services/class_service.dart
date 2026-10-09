import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisdom_portal_1/models/class_model.dart';

class ClassService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    'classes',
  );

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user logged in — cannot access data.");
    }
    return user.uid;
  }

  Stream<List<ClassModel>> streamClasses() {
    return _ref.where('userId', isEqualTo: _uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                ClassModel.fromJson(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<void> addClass(ClassModel classModel) async {
    final data = classModel.toJson();
    data['userId'] = _uid;
    await _ref.add(data);
  }

  Future<void> deleteClass(String id) async {
    await _ref.doc(id).delete();
  }
}
