// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/screens/home_screen.dart';
import 'package:shoppinglist/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSigningUp = false;
  String _email = "";

  Future<void> _signUpWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isSigningUp = true;
        });

        final String email = _emailController.text.trim();
        final String password = _passwordController.text;

        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Check if the user was successfully created
        if (userCredential.user != null) {
          await _createUserProfileDoc();

          // Clear text fields after successful sign-up
          _emailController.clear();
          _passwordController.clear();

          // Navigate to the HomeScreen
          // ignore: use_build_context_synchronously
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomeScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showAlert(context, "סיסמה חלשה");
        } else if (e.code == 'email-already-in-use') {
          _showAlert(context, "משתמש כבר רשום");
        }
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _isSigningUp = false;
        });
      }
    }
  }

  Future<void> _createUserProfileDoc() async {
    try {
      String? userId = _auth.currentUser?.uid;
      final CollectionReference collectionRef = _firestore.collection("users");
      final DocumentReference newDocRef = collectionRef.doc(userId);
      final docData = {
        "email": _email,
        "connections": [],
        "sendconnections": [],
        "connectionrequests": [],
      };
      await newDocRef.set(docData);
    } catch (e) {
      print(e);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _showAlert(BuildContext context, String alert) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(alert),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 26, 255),
              Color.fromARGB(255, 0, 166, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SizedBox(
            height: 400,
            width: 250,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "הרשמה",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.white,
                          ),
                        ),
                        hintText: "אימייל",
                        hintStyle: const TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.white,
                          ),
                        ),
                        hintTextDirection: TextDirection.rtl,
                        contentPadding: const EdgeInsets.all(10)),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your email';
                      } else if (!_isValidEmail(value!)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.white,
                          ),
                        ),
                        hintText: "סיסמה",
                        hintStyle: const TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.white,
                          ),
                        ),
                        hintTextDirection: TextDirection.rtl,
                        contentPadding: const EdgeInsets.all(10)),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      } else if (value!.length < 6) {
                        return 'Password should be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        _isSigningUp ? null : _signUpWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('הירשם',
                              style: TextStyle(color: Colors.blue)),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.app_registration, color: Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const SignInScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "התחבר",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Text("?כבר רשום",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomeScreen(),
            ),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.home, color: Colors.blue, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
