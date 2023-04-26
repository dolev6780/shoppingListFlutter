import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/screens/HomeScreen.dart';
import 'package:shoppinglist/screens/SignInScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String email = "";
  String password = "";

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showAlert(context, "סיסמה חלשה");
      } else if (e.code == 'email-already-in-use') {
        showAlert(context, "משתמש כבר רשום");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(email);
    print(password);
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: SizedBox(
          height: 400,
          width: 250,
          child: Form(
              child: Column(
            children: [
              const Text("הרשמה",
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
                  signUpWithEmailAndPassword(email, password);
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
                        child: Text('הירשם',
                            style: TextStyle(color: Colors.blue))),
                    SizedBox(width: 5),
                    Icon(Icons.app_registration, color: Colors.blue),
                  ],
                ),
              ),
              SizedBox(height: 10),
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
                            ));
                      },
                      child: const Text(
                        "התחבר",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900),
                      )),
                  const Text("?כבר רשום",
                      style: TextStyle(color: Colors.white)),
                ],
              )
            ],
          )),
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
          child: const Icon(Icons.home, color: Colors.blue, size: 32),
          backgroundColor: Colors.white),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

void showAlert(BuildContext context, String alert) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(alert),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
