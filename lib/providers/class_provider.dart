import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wisdom_portal_1/models/class_model.dart';
import 'package:wisdom_portal_1/services/class_service.dart';
import 'package:wisdom_portal_1/utils/error_helper.dart';

class ClassProvider extends ChangeNotifier {
  final ClassService _service = ClassService();
  List<ClassModel> _classes = [];
  String? _errorMessage;
  StreamSubscription<List<ClassModel>>? _sub;

  String? get errorMessage => _errorMessage;

  static const Map<String, int> _levelRank = {
    "play group": 0,
    "playgroup": 0,
    "pg": 0,
    "class pg": 0,
    "class play group": 0,
    "nursery": 1,
    "class nursery": 1,
    "prep": 2,
    "class prep": 2,
    "preparatory": 2,
  };

  String _normalize(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  int _rankOf(String name) => _levelRank[_normalize(name)] ?? -1;

  List<ClassModel> get classes {
    final sorted = List<ClassModel>.from(_classes);
    sorted.sort((a, b) => _compareClassNames(a.className, b.className));
    return sorted;
  }

  int get totalClasses => _classes.length;

  void listenToClasses() {
    _sub?.cancel();
    _sub = _service.streamClasses().listen(
      (list) {
        _classes = list;
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
    _sub?.cancel();
    super.dispose();
  }

  Future<void> addClass(ClassModel classed) async {
    try {
      await _service.addClass(classed);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _service.deleteClass(id);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  bool isClassExist(String className) {
    final target = _normalize(className);
    return _classes.any((c) => _normalize(c.className) == target);
  }

  bool isLastClass(String className) {
    final sortedClasses = classes;
    if (sortedClasses.isEmpty) return false;
    return _normalize(sortedClasses.last.className) == _normalize(className);
  }

  String? getNextClassName(String currentClassName) {
    final sortedClasses = classes;
    final target = _normalize(currentClassName);
    final currentIndex = sortedClasses.indexWhere(
      (c) => _normalize(c.className) == target,
    );

    if (currentIndex == -1 || currentIndex == sortedClasses.length - 1) {
      return null;
    }

    return sortedClasses[currentIndex + 1].className;
  }

  int _compareClassNames(String a, String b) {
    final aRank = _rankOf(a);
    final bRank = _rankOf(b);

    if (aRank != -1 && bRank != -1) {
      if (aRank != bRank) return aRank.compareTo(bRank);
      return _normalize(a).compareTo(_normalize(b));
    }
    if (aRank != -1) return -1;
    if (bRank != -1) return 1;

    final aNum = _extractClassNumber(a);
    final bNum = _extractClassNumber(b);

    if (aNum != null && bNum != null) {
      if (aNum != bNum) return aNum.compareTo(bNum);
      return _normalize(a).compareTo(_normalize(b));
    }
    if (aNum != null) return -1;
    if (bNum != null) return 1;

    return _normalize(a).compareTo(_normalize(b));
  }

  int? _extractClassNumber(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
