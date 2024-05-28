// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shoppinglist/screens/home_screen.dart';
import 'package:shoppinglist/screens/signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _email = "";
  String _password = "";

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Show a loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Hide the loading indicator after successful sign-in
        Navigator.pop(context);

        // Navigate to the home screen on successful sign-in
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        // Hide the loading indicator on authentication error
        Navigator.pop(context);

        if (e.code == 'user-not-found') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('No user found for that email.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (e.code == 'wrong-password') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Wrong password provided for that user.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Show a generic error message for other exceptions
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred. Please try again later.'),
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
    }
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: SizedBox(
                height: 500,
                width: double.infinity,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "התחברות",
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
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
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
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signInWithEmailAndPassword,
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
                              child: Text('התחבר',
                                  style: TextStyle(color: Colors.blue)),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward, color: Colors.blue),
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
                                      const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "הירשם",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          const Text("?עוד לא נרשמת",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset('assets/facebook_icon.png'),
                            iconSize: 36,
                          ),
                          const SizedBox(width: 25),
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset('assets/apple_icon.png'),
                            iconSize: 36,
                          ),
                          const SizedBox(width: 25),
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset('assets/google_icon.png'),
                            iconSize: 36,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
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
