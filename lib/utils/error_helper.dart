import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ErrorHelper {
  static const String generic = 'Something went wrong. Please try again.';
  static const String noInternet =
      'No internet connection. Please check your network and try again.';
  static const String timeout =
      'The request took too long. Please check your connection and try again.';

  /// Turns any error into a message a normal user can understand.
  static String getMessage(Object error) {
    // The technical text goes to the console only, never to the user.
    if (kDebugMode) debugPrint('ERROR: $error');

    // FirebaseAuthException extends FirebaseException, so check it first.
    if (error is FirebaseAuthException) return _authMessage(error.code);
    if (error is FirebaseException) return _firestoreMessage(error.code);
    if (error is SocketException) return noInternet;
    if (error is TimeoutException) return timeout;
    return generic;
  }

  static String _authMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-email':
        return 'Incorrect email. Please try again.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact the administrator.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return noInternet;
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact the administrator.';
      case 'requires-recent-login':
        return 'For security, please log in again and retry.';
      case 'user-token-expired':
        return 'Your session has expired. Please log in again.';
      default:
        return generic;
    }
  }

  static String _firestoreMessage(String code) {
    switch (code) {
      case 'unavailable':
        return 'Service is temporarily unavailable. Please check your internet and try again.';
      case 'deadline-exceeded':
        return timeout;
      case 'permission-denied':
        return "You don't have permission to do this.";
      case 'unauthenticated':
        return 'Your session has expired. Please log in again.';
      case 'not-found':
        return 'The requested record was not found.';
      case 'already-exists':
        return 'This record already exists.';
      case 'resource-exhausted':
        return 'Too many requests right now. Please try again later.';
      case 'cancelled':
        return 'The action was cancelled. Please try again.';
      case 'aborted':
        return 'The action could not be completed. Please try again.';
      case 'invalid-argument':
        return 'Some of the information is not valid. Please check and try again.';
      case 'failed-precondition':
        return 'This action cannot be done right now. Please try again later.';
      case 'data-loss':
      case 'internal':
      case 'unknown':
      case 'unimplemented':
        return generic;
      default:
        return generic;
    }
  }
}
