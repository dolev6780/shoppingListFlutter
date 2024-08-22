import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/signin_screen.dart';
import 'package:text_divider/text_divider.dart';

import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isSigningUp = false;
  String _email = "";
  String _name = "";

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _showAlert(String alert) {
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 20, 67, 117),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
              height: 600,
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
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
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _nameController,
                          onChanged: (value) {
                            setState(() {
                              _name = value;
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
                            hintText: "שם מלא",
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
                            contentPadding: const EdgeInsets.all(10),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
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
                            contentPadding: const EdgeInsets.all(10),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your email';
                            } else if (!_isValidEmail(value!)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _passwordController,
                          onChanged: (value) {
                            setState(() {});
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
                            hintText: "סיסמא",
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
                            contentPadding: const EdgeInsets.all(10),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your password';
                            } else if (value!.length < 6) {
                              return 'Password should be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSigningUp = true;
                            });

                            try {
                              await _authService.signUpWithEmailAndPassword(
                                  context,
                                  _email,
                                  _passwordController.text,
                                  _name);
                            } catch (e) {
                              _showAlert(
                                  "An error occurred. Please try again.");
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSigningUp = false;
                                });
                              }
                            }
                          }
                        },
                        child: _isSigningUp
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "הרשמה",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 100),
                      TextDivider.horizontal(
                        text: const Text('?כבר רשום',
                            style: TextStyle(color: Colors.white)),
                        color: Colors.white,
                        thickness: 1,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const SignInScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "היכנס",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
