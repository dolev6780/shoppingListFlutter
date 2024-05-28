// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyConnectionsList extends StatefulWidget {
  final List myConnections;
  const MyConnectionsList({super.key, required this.myConnections});

  @override
  State<MyConnectionsList> createState() => _MyConnectionsListState();
}

class _MyConnectionsListState extends State<MyConnectionsList> {
//get firestore for deleting and updating purpose(current user and connection user)
  var userConnection = "";

  Future<void> removeItem(int i) async {
    setState(() {
      userConnection = widget.myConnections[i]['id'];
      widget.myConnections.removeAt(i);
    });
    await deleteRequest();
  }

  Future<void> deleteRequest() async {
    try {
      // Get a reference to auth that contains the user info
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Get a reference to the document that contains the connetion
      var userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid);

      var userConnectionDocRef =
          FirebaseFirestore.instance.collection('users').doc(userConnection);

      // Update the field in the document
      //First we need to create a list for the user connection
      List removeFromUserConnections = [];
      //Then we need to fill the list with this user connections
      await userConnectionDocRef.get().then(
        (doc) {
          if (doc.exists) {
            setState(() {
              removeFromUserConnections
                  .addAll(doc.data()?['connections'] ?? []);
            });
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );

      //After that we find where the current user is in the user connections list and remove it
      var item = removeFromUserConnections
          .where((element) => element['user'] == auth.currentUser?.email);
      removeFromUserConnections.remove(item.first);

      //updating the user connections list without the current user
      await userConnectionDocRef
          .update({'connections': removeFromUserConnections});
      //updating the current user connections list without the user connection
      await userDocRef.update({'connections': widget.myConnections});
    } catch (e) {
      print('Error updating field: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: widget.myConnections.isNotEmpty
          ? ListView.builder(
              itemCount: widget.myConnections.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            removeItem(index);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(left: 8, right: 8),
                  title: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      CircleAvatar(
                          radius: 15,
                          child: Text(widget.myConnections[index]['user']
                              .toString()
                              .toUpperCase()
                              .substring(0, 1))),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(widget.myConnections[index]['user']),
                    ],
                  ),
                );
              },
            )
          : const SizedBox(),
    );
  }
}
