import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/screens/CreateListScreen.dart';
import 'package:shoppinglist/screens/SignInScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String? _email = "";

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (!(_user?.email == null)) {
      _email = _user?.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_email!),
        automaticallyImplyLeading: false,
      ),
      endDrawer: Drawer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                _email!.isEmpty
                    ? TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const SignInScreen(),
                              ));
                        },
                        child: const Text("התחברות"))
                    : TextButton(onPressed: () {}, child: Text(_email!)),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _auth.signOut();
                        _email = "";
                      });
                    },
                    child: const Text("התנתקות"))
              ],
            ),
          ),
        ),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const CreateListScreen(),
              ));
        },
        label: const Text("צור רשימה חדשה"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
