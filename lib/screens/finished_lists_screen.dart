// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/screens/home_screen.dart';
import 'package:shoppinglist/services/theme_provider.dart';

import '../components/app_bar.dart';
import 'my_connections_screen.dart';

class FinishedListsScreen extends StatefulWidget {
  const FinishedListsScreen({super.key});

  @override
  State<FinishedListsScreen> createState() => _FinishedListsScreenState();
}

class _FinishedListsScreenState extends State<FinishedListsScreen> {
  User? _user;
  List<Map<String, dynamic>> finishedLists = [];
  late QuerySnapshot snapshot;
  bool finish = false;
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    var subCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc("${_user?.uid}")
        .collection('shoplists');
    if (!(_user?.uid == null)) {
      subCollectionRef.snapshots().listen((querySnapshot) {
        try {
          snapshot = querySnapshot;
          List<Map<String, dynamic>> newFinishedLists = [];
          querySnapshot.docs
              .where((doc) => doc.data()['finished'] == true)
              .forEach((doc) {
            newFinishedLists.add({
              'title': doc.data()['title'],
              'date': doc.data()['date'],
              'list': doc.data()['list']
            });
          });
          setState(() {
            finishedLists = newFinishedLists;
          });
        } catch (e, stackTrace) {
          print('Error in subCollectionRef.snapshots().listen(): $e');
          print('$stackTrace');
        }
      });
    } else {
      finishedLists = [];
    }
  }

  int _currentIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (_currentIndex) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomeScreen(),
            ));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const MyConnectionsScreen(),
            ));
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Appbar(
            title: "היסטוריית רשימות",
            backBtn: true,
            color: themeColor,
          )),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: finishedLists.isNotEmpty
            ? ListView.builder(
                itemCount: finishedLists.length,
                addAutomaticKeepAlives: true,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.blue[400],
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {},
                          child: ListTile(
                            title: Text(
                              finishedLists[index]['title'],
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              finishedLists[index]['date'],
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: Colors.grey.shade50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  );
                },
              )
            : const SizedBox(),
      ),
    );
  }
}
