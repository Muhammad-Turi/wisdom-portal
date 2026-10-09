import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisdom_portal_1/models/student_model.dart';

class StudentService {
  final CollectionReference _studentsRef = FirebaseFirestore.instance
      .collection('students');

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user logged in — cannot access data.");
    }
    return user.uid;
  }

  Stream<List<StudentModel>> streamStudents() {
    return _studentsRef.where('userId', isEqualTo: _uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map(
            (doc) => StudentModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<void> addStudent(StudentModel student) async {
    final data = student.toMap();
    data['userId'] = _uid;
    await _studentsRef.doc(student.id).set(data);
  }

  Future<void> updateStudent(StudentModel student) async {
    final data = student.toMap();
    data['userId'] = _uid;
    await _studentsRef.doc(student.id).update(data);
  }

  Future<void> deleteStudent(String id) async {
    await _studentsRef.doc(id).delete();
  }
}
