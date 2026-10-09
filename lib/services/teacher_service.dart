import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisdom_portal_1/models/teacher_model.dart';

class TeacherService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    'teachers',
  );

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user logged in — cannot access data.");
    }
    return user.uid;
  }

  Stream<List<TeacherModel>> streamTeachers() {
    return _ref.where('userId', isEqualTo: _uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => TeacherModel.fromJson(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<void> addTeacher(TeacherModel teacher) async {
    final data = teacher.toJson();
    data['userId'] = _uid;
    await _ref.doc(teacher.id).set(data);
  }

  Future<void> updateTeacher(TeacherModel teacher) async {
    final data = teacher.toJson();
    data['userId'] = _uid;
    await _ref.doc(teacher.id).update(data);
  }

  Future<void> deleteTeacher(String id) async {
    await _ref.doc(id).delete();
  }
}
