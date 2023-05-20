import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SendConnectionsList extends StatefulWidget {
  final List sendConnections;
  const SendConnectionsList({super.key, required this.sendConnections});

  @override
  State<SendConnectionsList> createState() => _SendConnectionsListState();
}

class _SendConnectionsListState extends State<SendConnectionsList> {
//get firestore for deleting and updating purpose(current user and connection user)
  var userWhoGotRequest = "";

  Future<void> removeItem(int i) async {
    setState(() {
      userWhoGotRequest = widget.sendConnections[i]['id'];
      widget.sendConnections.removeAt(i);
    });
    await deleteRequest();
  }

  Future<void> deleteRequest() async {
    try {
      // Get a reference to auth that contains the user info
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Get a reference to the document that contains the send connection
      var userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid);

      var userWhoGotRequestDocRef =
          FirebaseFirestore.instance.collection('users').doc(userWhoGotRequest);

      // Update the field in the document
      //First we need to create a list for the user who got the request
      List removeFromUserWhoGotRequest = [];
      //Then we need to fill the list with this user sendConnections
      await userWhoGotRequestDocRef.get().then(
        (doc) {
          if (doc.exists) {
            setState(() {
              removeFromUserWhoGotRequest
                  .addAll(doc.data()?['connectionsrequests'] ?? []);
            });
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );

      //After that we find where the current user is in the user who got request list and remove it
      var item = removeFromUserWhoGotRequest
          .where((element) => element['user'] == auth.currentUser?.email);
      removeFromUserWhoGotRequest.remove(item.first);

      //updating the user connectionsrequests list without the current user
      await userWhoGotRequestDocRef
          .update({'connectionsrequests': removeFromUserWhoGotRequest});
      //updating the current user sendconnections list without the user who send request
      await userDocRef.update({'sendconnections': widget.sendConnections});
    } catch (e) {
      print('Error updating field: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: widget.sendConnections.isNotEmpty
          ? ListView.builder(
              itemCount: widget.sendConnections.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            removeItem(index);
                          },
                          icon: Icon(Icons.delete),
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
                          child: Text(widget.sendConnections[index]['user']
                              .toString()
                              .toUpperCase()
                              .substring(0, 1))),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(widget.sendConnections[index]['user']),
                    ],
                  ),
                );
              },
            )
          : SizedBox(),
    );
  }
}
