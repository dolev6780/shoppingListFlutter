import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shoppinglist/screens/HomeScreen.dart';
import 'package:shoppinglist/screens/SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String email = "";
  String password = "";
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('object');
      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 450,
            width: 250,
            child: Form(
                child: Column(
              children: [
                const Text("התחברות",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  onChanged: (value) {
                    setState(() {
                      email = emailController.text;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            style: BorderStyle.solid, color: Colors.white)),
                    hintText: "אימייל",
                    hintStyle: const TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            style: BorderStyle.solid, color: Colors.white)),
                    hintTextDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  onChanged: (value) {
                    setState(() {
                      password = passwordController.text;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              style: BorderStyle.solid, color: Colors.white)),
                      hintText: "סיסמה",
                      hintStyle: const TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              style: BorderStyle.solid, color: Colors.white)),
                      hintTextDirection: TextDirection.rtl),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    signInWithEmailAndPassword(email, password);
                  },
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
                              style: TextStyle(color: Colors.blue))),
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
                              ));
                        },
                        child: const Text(
                          "הירשם",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900),
                        )),
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
            )),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const HomeScreen(),
                ));
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.home, color: Colors.blue, size: 32)),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
