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
  List shopListTitles = [{}];

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
        List newShopListTitles = [];
        querySnapshot.docs.forEach((doc) {
          newShopListTitles
              .add({'title': doc.data()['title'], 'date': doc.data()['date']});
        });
        setState(() {
          shopListTitles = newShopListTitles;
        });
      });
    } else {
      shopListTitles = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shopListTitles.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.all(10),
          title: Container(
            height: 60,
            child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  elevation: 6,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 10),
                  Text(shopListTitles[index]['date'].toString(),
                      style: TextStyle(fontSize: 16)),
                  Spacer(),
                  Text(shopListTitles[index]['title'].toString(),
                      style: TextStyle(fontSize: 24)),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
