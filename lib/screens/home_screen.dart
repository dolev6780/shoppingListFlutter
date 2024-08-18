import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/bottom_modal_create_list.dart';
import 'package:shoppinglist/components/drawer.dart';
import 'package:shoppinglist/components/list_titles.dart';
import 'package:shoppinglist/screens/signin_screen.dart';
import 'package:shoppinglist/services/theme_provider.dart';
import '../components/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            _titles = fetchedTitles;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch lists. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          if (mounted) {
            setState(() {
              _userName = documentSnapshot['displayName'];
            });
          }
        } else {
          _userName = "unknown";
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('no user found'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(
          title: "הרשימות שלי",
          backBtn: false,
          color: themeColor,
        ),
      ),
      endDrawer: CustomDrawer(userName: _userName),
      body: RefreshIndicator(
          onRefresh: _refreshLists,
          child: ListTitles(refreshLists: _refreshLists)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: themeColor,
        label: const Text(
          "רשימה חדשה",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
