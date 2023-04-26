import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListTitles extends StatefulWidget {
  const ListTitles({super.key});

  @override
  State<ListTitles> createState() => ListTitlesState();
}

class ListTitlesState extends State<ListTitles> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  List<String> shopListTitles = [];

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
        List<String> newShopListTitles = [];
        querySnapshot.docs.forEach((doc) {
          newShopListTitles.add(doc.data()['title']);
        });
        setState(() {
          shopListTitles = newShopListTitles;
        });
      });
    } else {
      print(_user?.uid);
      shopListTitles = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shopListTitles.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(shopListTitles[index]),
        );
      },
    );
  }
}
