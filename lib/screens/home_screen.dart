import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/bottom_modal_create_list.dart';
import 'package:shoppinglist/components/list_titles.dart';
import 'package:shoppinglist/screens/finished_lists_screen.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/screens/settings_screen.dart';
import 'package:shoppinglist/screens/signin_screen.dart';
import '../components/app_bar.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  // ignore: unused_field
  List<String> _titles = [];
  String _userName = "";
  @override
  void initState() {
    super.initState();
    _refreshLists();
    _getName();
  }

  Future<void> _refreshLists() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = Provider.of<User?>(context, listen: false);

      if (user != null) {
        final QuerySnapshot snapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('lists')
            .get();

        List<String> fetchedTitles =
            snapshot.docs.map((doc) => doc['title'] as String).toList();

        setState(() {
          _titles = fetchedTitles;
        });
      }
    } catch (e) {
      // Handle error (e.g., show an error message)
      print("Error fetching lists: $e");
    }
  }

  Future<void> _getName() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = Provider.of<User?>(context, listen: false);

      if (user != null) {
        final DocumentSnapshot documentSnapshot =
            await firestore.collection('users').doc(user.uid).get();

        if (documentSnapshot.exists) {
          setState(() {
            _userName = documentSnapshot['displayName'];
          });
        } else {
          // Handle the case when the document does not exist
        }
      }
    } catch (e) {
      // Handle error (e.g., show an error message)
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const SignInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const SignInScreen();
    }
    String name = _userName;
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Appbar(
            title: "הרשימות שלי",
            backBtn: false,
            color: Color.fromARGB(255, 20, 67, 117),
          ),
        ),
        endDrawer: Drawer(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(50, 70, 50, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 5),
                        Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(50),
                          child: CircleAvatar(
                            maxRadius: 30,
                            backgroundColor:
                                const Color.fromARGB(255, 20, 67, 117),
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : user.email.toString()[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name.isNotEmpty
                              ? name
                              : user.email.toString()[0].toUpperCase() +
                                  user.email.toString().substring(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    const Divider(height: 1, thickness: 1),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const FinishedListsScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.history,
                                    color: Color.fromARGB(255, 20, 67, 117)),
                                Text(
                                  "הסטוריית רשימות",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const MyConnectionsScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.people,
                                    color: Color.fromARGB(255, 20, 67, 117)),
                                Text(
                                  "אנשי הקשר שלי",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const SettingsScreen(),
                                  ));
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.settings,
                                    color: Color.fromARGB(255, 20, 67, 117)),
                                Text(
                                  "הגדרות",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    user.email!.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.all(10),
                            child: TextButton(
                              onPressed: _signOut,
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Color.fromARGB(255, 20, 67, 117),
                                  ),
                                  Text(
                                    "התנתקות",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const Text(""),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "copyright 2023",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ListTitles(refreshLists: _refreshLists),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () => {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => BottomModalCreateList(
                  onListCreated: _refreshLists,
                ),
              )
            },
            backgroundColor: const Color.fromARGB(255, 20, 67, 117),
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
        ));
  }
}
