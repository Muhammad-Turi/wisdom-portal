import 'package:flutter/material.dart';
import 'package:wisdom_portal_1/models/teacher_model.dart';
import 'package:wisdom_portal_1/services/teacher_service.dart';
import 'package:wisdom_portal_1/utils/error_helper.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherService _service = TeacherService();
  List<TeacherModel> _teacher = [];
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  List<TeacherModel> get teacher => _teacher;

  int get totalTeacher => teacher.length;

  void listenToTeachers() {
    _service.streamTeachers().listen(
      (list) {
        _teacher = list;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = ErrorHelper.getMessage(error);
        notifyListeners();
      },
    );
  }

  Future<void> addTeacher(TeacherModel teacher) async {
    try {
      await _service.addTeacher(teacher);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await _service.deleteTeacher(id);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTeacher(TeacherModel teacher) async {
    try {
      await _service.updateTeacher(teacher);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  List<TeacherModel> searchTeacher(String query) {
    if (query.isEmpty) return _teacher;

    return _teacher
        .where((t) => t.teacherName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
