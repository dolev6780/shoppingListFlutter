import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/services/firestore_service.dart';

class AuthProviding with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  User? _user;
  String? _displayName;

  AuthProviding() {
    _auth.authStateChanges().listen(_authStateChanged);
  }

  User? get user => _user;
  String? get displayName => _displayName;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _authStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      _displayName = await _firestoreService.getUserDisplayName(user.uid);
    } else {
      _displayName = null;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
