import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/signup_screen.dart';
import 'package:shoppinglist/services/auth_service.dart';
import 'package:text_divider/text_divider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isSigningIn = false;
  String _email = "";

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _showAlert(String alert) {
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
                        "התחברות",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Schyler"),
                      ),
                      const SizedBox(height: 40),
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
                              _isSigningIn = true;
                            });

                            try {
                              await _authService.signInWithEmailAndPassword(
                                context,
                                _email,
                                _passwordController.text,
                              );
                            } catch (e) {
                              _showAlert(
                                  "An error occurred. Please try again.");
                            } finally {
                              setState(() {
                                _isSigningIn = false;
                              });
                            }
                          }
                        },
                        child: _isSigningIn
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "כניסה",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      TextButton(
                          onPressed: () async {
                            await _authService.signInWithGoogle(context);
                          },
                          child: Container(
                            width: 190,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google_icon.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      "הירשם עם גוגל",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 20, 67, 117)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 100),
                      TextDivider.horizontal(
                        text: const Text('?לא רשום',
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
                                  const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "הרשמה",
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
