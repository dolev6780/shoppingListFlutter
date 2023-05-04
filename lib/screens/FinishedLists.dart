import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'TheListScreen.dart';

class FinishedLists extends StatefulWidget {
  const FinishedLists({super.key});

  @override
  State<FinishedLists> createState() => _FinishedListsState();
}

class _FinishedListsState extends State<FinishedLists> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('הסטוריית רשימות'),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
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
                                style: TextStyle(
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
                        SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  },
                )
              : SizedBox(),
        ));
  }
}
