import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wisdom_portal_1/models/purchase_model.dart';
import 'package:wisdom_portal_1/services/purchase_service.dart';
import 'package:wisdom_portal_1/utils/error_helper.dart';

class PurchaseProvider extends ChangeNotifier {
  final PurchaseService _service = PurchaseService();
  List<PurchaseModel> _purchase = [];
  String? _errorMessage;

  StreamSubscription<List<PurchaseModel>>? _subscription;

  Map<String, List<PurchaseModel>>? _byStudent;

  String? get errorMessage => _errorMessage;

  List<PurchaseModel> get purchase => _purchase;

  @override
  void notifyListeners() {
    _byStudent = null;
    super.notifyListeners();
  }

  void listenToPurchases() {
    _subscription?.cancel();
    _subscription = _service.streamPurchases().listen(
      (list) {
        _purchase = list;
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

  Future<void> addPurchase(PurchaseModel purchase) async {
    try {
      await _service.addPurchase(purchase);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      await _service.deletePurchase(id);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePurchase(PurchaseModel purchase) async {
    try {
      await _service.updatePurchase(purchase);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePurchasesByStudent(String studentId) async {
    final ids = getPurchasesByStudent(studentId).map((p) => p.id).toList();
    await Future.wait(ids.map((id) => _service.deletePurchase(id)));
  }

  Map<String, List<PurchaseModel>> _buildIndex() {
    final map = <String, List<PurchaseModel>>{};
    for (final p in _purchase) {
      map.putIfAbsent(p.studentId, () => []).add(p);
    }
    return map;
  }

  List<PurchaseModel> getPurchasesByStudent(String studentId) {
    final index = _byStudent ??= _buildIndex();
    final list = index[studentId];
    if (list == null) return [];

    return List<PurchaseModel>.of(list);
  }
}
