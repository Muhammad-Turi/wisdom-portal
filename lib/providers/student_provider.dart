import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wisdom_portal_1/models/student_model.dart';
import 'package:wisdom_portal_1/services/student_service.dart';
import 'package:wisdom_portal_1/utils/error_helper.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  final StudentService _service = StudentService();

  StreamSubscription<List<StudentModel>>? _subscription;

  List<StudentModel> get students => _students;

  List<StudentModel> get activeStudents =>
      _students.where((s) => !s.isGraduated).toList();

  List<StudentModel> get graduatedStudents =>
      _students.where((s) => s.isGraduated).toList();

  int get totalStudent => activeStudents.length;

  int get graduatedCount => graduatedStudents.length;

  int? _paidCache;
  int? _unpaidCache;
  int _cacheMonthKey = 0;

  int _currentMonthKey() {
    final now = DateTime.now();
    return now.year * 100 + now.month;
  }

  @override
  void notifyListeners() {
    _paidCache = null;
    _unpaidCache = null;
    super.notifyListeners();
  }

  bool _hasUnpaidFee(StudentModel s) => s.getFeeStatus().any((m) => !m.isPaid);

  void _ensureFeeCounts() {
    final monthKey = _currentMonthKey();
    if (_paidCache != null &&
        _unpaidCache != null &&
        _cacheMonthKey == monthKey) {
      return;
    }

    int paid = 0;
    int unpaid = 0;
    for (final s in _students) {
      if (s.isGraduated) continue;
      if (_hasUnpaidFee(s)) {
        unpaid++;
      } else {
        paid++;
      }
    }

    _paidCache = paid;
    _unpaidCache = unpaid;
    _cacheMonthKey = monthKey;
  }

  int get unpaidStudent {
    _ensureFeeCounts();
    return _unpaidCache!;
  }

  int get paidStudent {
    _ensureFeeCounts();
    return _paidCache!;
  }

  Future<void> addStudent(StudentModel student) async {
    try {
      await _service.addStudent(student);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _service.deleteStudent(id);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStudent(StudentModel student) async {
    try {
      await _service.updateStudent(student);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  void listenToStudents() {
    _subscription?.cancel();
    _subscription = _service.streamStudents().listen(
      (list) {
        _students = list;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = ErrorHelper.getMessage(error);
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<StudentModel> getStudentsByClass(String className) {
    return _students
        .where((s) => !s.isGraduated && s.className == className)
        .toList();
  }

  StudentModel getStudentById(String id) {
    return _students.firstWhere((s) => s.id == id);
  }

  Future<void> promoteStudent(String studentId, String newClassName) async {
    final student = getStudentById(studentId);
    student.promoteToClass(newClassName);
    await updateStudent(student);
  }

  Future<void> graduateMultipleStudents(List<String> studentIds) async {
    final writes = <Future<void>>[];
    for (final id in studentIds) {
      final student = getStudentById(id);
      student.graduate();
      writes.add(updateStudent(student));
    }
    await Future.wait(writes);
  }

  Future<void> promoteMultipleStudents(
    List<String> studentIds,
    String newClassName,
  ) async {
    final writes = <Future<void>>[];
    for (final id in studentIds) {
      final student = getStudentById(id);
      student.promoteToClass(newClassName);
      writes.add(updateStudent(student));
    }
    await Future.wait(writes);
  }

  Future<void> undoGraduation(String studentId) async {
    final student = getStudentById(studentId);
    student.undoGraduation();
    await updateStudent(student);
  }

  List<StudentModel> searchStudent(String query, String className) {
    final classStudents = getStudentsByClass(className);

    if (query.isEmpty) {
      return classStudents;
    }

    final q = query.toLowerCase();
    return classStudents
        .where(
          (s) =>
              s.studentName.toLowerCase().contains(q) ||
              s.rollNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  List<StudentModel> searchAllStudent(String query) {
    final active = activeStudents;

    if (query.isEmpty) {
      return active;
    }

    final q = query.toLowerCase();
    return active
        .where(
          (s) =>
              s.studentName.toLowerCase().contains(q) ||
              s.className.toLowerCase().contains(q),
        )
        .toList();
  }

  List<StudentModel> searchGraduated(String query) {
    final graduated = graduatedStudents;

    if (query.isEmpty) {
      return graduated;
    }

    final q = query.toLowerCase();
    return graduated
        .where(
          (s) =>
              s.studentName.toLowerCase().contains(q) ||
              s.rollNumber.toLowerCase().contains(q),
        )
        .toList();
  }
}
