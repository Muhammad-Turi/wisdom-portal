import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wisdom_portal_1/services/auth_service.dart';
import 'package:wisdom_portal_1/utils/error_helper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  StreamSubscription<User?>? _authSub;

  bool _isLoading = false;
  String? _errorMsg;
  User? _user;
  bool _isInitialized = false;
  bool get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;
  User? get user => _user;

  AuthProvider() {
    _user = _service.currentUser;
    _service.authStateChanges.listen((user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMsg = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    _errorMsg = null;

    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        _errorMsg = "Email and password cannot be empty.";
        setLoading(false);
        return false;
      }

      await _service.login(email: email, password: password);
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMsg = _service.getErrorMessage(e);
      setLoading(false);
      return false;
    } catch (e) {
      _errorMsg = ErrorHelper.getMessage(e);
      setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    setLoading(true);
    _errorMsg = null;

    try {
      if (name.trim().isEmpty ||
          email.trim().isEmpty ||
          password.trim().isEmpty) {
        _errorMsg = "Please fill in all details correctly.";
        setLoading(false);
        return false;
      }

      await _service.signUp(name: name, email: email, password: password);
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMsg = _service.getErrorMessage(e);
      setLoading(false);
      return false;
    } catch (e) {
      _errorMsg = ErrorHelper.getMessage(e);
      setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    setLoading(true);
    _errorMsg = null;

    try {
      if (email.trim().isEmpty) {
        _errorMsg = "Please enter your email.";
        setLoading(false);
        return false;
      }

      await _service.sendPasswordResetEmail(email);
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMsg = _service.getErrorMessage(e);
      setLoading(false);
      return false;
    } catch (e) {
      _errorMsg = ErrorHelper.getMessage(e);
      setLoading(false);
      return false;
    }
  }

  Future<void> logOut() async {
    try {
      await _service.logOut();
      _user = null;
      _errorMsg = null;
      notifyListeners();
    } catch (e) {
      _errorMsg = ErrorHelper.getMessage(e);
      notifyListeners();
    }
  }
}
