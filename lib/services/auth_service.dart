import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  try {
    // Check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase not initialized - auth unavailable');
      return null;
    }
    return FirebaseAuth.instance;
  } catch (e) {
    debugPrint('FirebaseAuth.instance error: $e');
    return null;
  }
});

class AuthService {
  final FirebaseAuth? _auth;

  AuthService(this._auth);

  Future<User?> signIn(String email, String password) async {
    if (_auth == null) {
      throw Exception('Firebase Auth is not available');
    }
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signUp(String email, String password) async {
    if (_auth == null) {
      throw Exception('Firebase Auth is not available');
    }
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_auth == null) return;
    await _auth!.signOut();
  }

  User? get currentUser => _auth?.currentUser;
}

final authServiceProvider = Provider<AuthService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthService(auth);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  try {
    final auth = ref.watch(firebaseAuthProvider);
    if (auth == null) {
      // If Firebase is not initialized, return stream with null user
      return Stream.value(null);
    }
    return auth.authStateChanges();
  } catch (e) {
    // If Firebase is not initialized, return stream with null user
    debugPrint('Auth state changes error: $e');
    return Stream.value(null);
  }
});

