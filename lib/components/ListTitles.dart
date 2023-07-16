// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/screens/TheListScreen.dart';

class ListTitles extends StatefulWidget {
  const ListTitles({Key? key}) : super(key: key);

  @override
  State<ListTitles> createState() => ListTitlesState();
}

class ListTitlesState extends State<ListTitles> {
  User? _user;
  List<Map<String, dynamic>> shopListTitles = [];
  List<bool> isOpen = [];
  late QuerySnapshot snapshot;

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
        snapshot = querySnapshot;
        List<Map<String, dynamic>> newShopListTitles = [];

        querySnapshot.docs
            .where((doc) => doc.data()['finished'] == false)
            .forEach((doc) {
          newShopListTitles.add({
            'creator': doc.data()['creator'],
            'title': doc.data()['title'],
            'date': doc.data()['date'],
            'list': doc.data()['list'],
            'docId': doc.id // Add the doc id to the map
          });
        });
        setState(() {
          shopListTitles = newShopListTitles;
          isOpen = List<bool>.generate(shopListTitles.length, (index) => false);
        });
      });
    } else {
      shopListTitles = [];
    }
  }

  void deleteList(docId) {
    var subCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc("${_user?.uid}")
        .collection('shoplists')
        .doc(docId);
    subCollectionRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: shopListTitles.isNotEmpty
          ? ListView.builder(
              itemCount: shopListTitles.length,
              addAutomaticKeepAlives: true,
              itemBuilder: (BuildContext context, int index) {
                var docId = shopListTitles[index]
                    ['docId']; // Get the doc id from the map
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    TheListScreen(
                                  creator: shopListTitles[index]['creator'],
                                  title: shopListTitles[index]['title'],
                                  list: shopListTitles[index]['list'],
                                  docId: docId,
                                  uid: "${_user?.uid}",
                                ),
                              ));
                        },
                        child: ListTile(
                          trailing: Text(
                            "${shopListTitles[index]['creator']?.toString().substring(0, shopListTitles[index]['creator'].toString().indexOf('@'))} :יוצר",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          title: Text(
                            shopListTitles[index]['title'],
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            shopListTitles[index]['date'],
                            textDirection: TextDirection.rtl,
                            style: TextStyle(color: Colors.grey.shade50),
                          ),
                          leading: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    deleteList(docId);
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white, size: 24),
                                ),
                              ],
                            ),
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
          : SizedBox(),
    );
  }
}
