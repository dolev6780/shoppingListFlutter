import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProviding with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProviding() {
    _auth.authStateChanges().listen(_authStateChanged);
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get user => _user;

  void _authStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
