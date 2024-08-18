import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/screens/home_screen.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // After signing in, create user profile document
      await _createUserProfileDoc(
          googleUser.email, googleUser.displayName.toString());

      // Navigate to the HomeScreen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      }

      return userCredential.user;
    } catch (e) {
      _showAlert(context,
          "An error occurred during Google sign-in. Please try again.");
      return null;
    }
  }

  Future<void> _createUserProfileDoc(String email, String displayName) async {
    try {
      String? userId = _auth.currentUser?.uid;
      final CollectionReference collectionRef = _firestore.collection("users");
      final DocumentReference newDocRef = collectionRef.doc(userId);

      final String connectId = const Uuid().v4();
      const Color defaultColor = Color.fromARGB(255, 20, 67, 117);
      String currentColorHex =
          '#${defaultColor.value.toRadixString(16).substring(2)}';
      final docData = {
        "email": email,
        "displayName": displayName,
        "connections": [],
        "connectId": connectId,
        "themeColor": currentColorHex
      };

      await newDocRef.set(docData);
    } catch (e) {
      // Handle error silently or log it
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Hide the loading indicator and navigate to the home screen
      if (context.mounted) {
        Navigator.pop(context); // Close the loading indicator
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Hide the loading indicator

      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = 'An error occurred. Please try again later.';
      }

      _showAlert(context, errorMessage);
    }
  }

  Future<void> signUpWithEmailAndPassword(BuildContext context, String email,
      String password, String displayName) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _createUserProfileDoc(email, displayName);

        // Navigate to the HomeScreen
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomeScreen(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = "סיסמה חלשה";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "משתמש כבר רשום";
      } else {
        errorMessage = "An error occurred. Please try again later.";
      }

      _showAlert(context, errorMessage);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
