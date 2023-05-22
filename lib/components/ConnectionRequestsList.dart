import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConnectionRequestsList extends StatefulWidget {
  final List connectionRequest;
  const ConnectionRequestsList({super.key, required this.connectionRequest});

  @override
  State<ConnectionRequestsList> createState() => _ConnectionRequestsListState();
}

class _ConnectionRequestsListState extends State<ConnectionRequestsList> {
//get firestore for deleting and updating purpose(current user and connection user)
  var userWhoSendRequest;

  Future<void> removeItem(int i) async {
    setState(() {
      userWhoSendRequest = widget.connectionRequest[i]['id'];
      widget.connectionRequest.removeAt(i);
    });
    await deleteRequest();
  }

  Future<void> deleteRequest() async {
    try {
      // Get a reference to auth that contains the user info
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Get a reference to the document that contains the request
      var userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid);

      var userWhoSendRequestDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userWhoSendRequest);

      // Update the field in the document
      //First we need to create a list for the user who send the request
      List removeFromUserWhoSendRequest = [];
      //Then we need to fill the list wuth this user sendRequests
      await userWhoSendRequestDocRef.get().then(
        (doc) {
          if (doc.exists) {
            setState(() {
              removeFromUserWhoSendRequest
                  .addAll(doc.data()?['sendconnections'] ?? []);
            });
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );
      //After that we find where the current user is in the user who send request list and remove it
      var item = removeFromUserWhoSendRequest
          .where((element) => element['user'] == auth.currentUser?.email);
      removeFromUserWhoSendRequest.remove(item.first);

      //updating the user sendconnections list without the current user
      await userWhoSendRequestDocRef
          .update({'sendconnections': removeFromUserWhoSendRequest});
      //updating the current user connectionsrequests list without the user who send request
      await userDocRef
          .update({'connectionsrequests': widget.connectionRequest});
    } catch (e) {
      print('Error updating field: $e');
    }
  }

  Future<void> acceptRequest(i) async {
    try {
      // Get a reference to auth that contains the user info
      final FirebaseAuth auth = FirebaseAuth.instance;
      userWhoSendRequest = await widget.connectionRequest[i]['id'];
      Map<String, dynamic> userWhoSendData = {
        'user': widget.connectionRequest[i]['user'],
        'id': widget.connectionRequest[i]['id'],
        'nickName': ""
      };
      Map<String, dynamic> userData = {
        'user': auth.currentUser?.email,
        'id': auth.currentUser?.uid,
        'nickName': ""
      };
      // Get a reference to the document that contains the request
      var userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid);

      var userWhoSendRequestDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userWhoSendRequest);

      // Update the field in the document
      //First we need to create a list for the user who send the request
      List userWhoSendRequestConnections = [];
      //Then we need to fill the list wuth this user connections
      await userWhoSendRequestDocRef.get().then(
        (doc) {
          if (doc.exists) {
            setState(() {
              userWhoSendRequestConnections
                  .addAll(doc.data()?['connections'] ?? []);
            });
          }
          userWhoSendRequestConnections.add(userData);
        },
        onError: (e) => print("Error getting document: $e"),
      );

      List currentUserConnections = [];
      //Then we need to fill the list wuth this user connections
      await userWhoSendRequestDocRef.get().then(
        (doc) {
          if (doc.exists) {
            setState(() {
              currentUserConnections.addAll(doc.data()?['connections'] ?? []);
            });
          }
          currentUserConnections.add(userWhoSendData);
        },
        onError: (e) => print("Error getting document: $e"),
      );
      //updating the user connections list
      await userWhoSendRequestDocRef
          .update({'connections': userWhoSendRequestConnections});
      //updating the current user connections list
      await userDocRef.update({'connections': currentUserConnections});
    } catch (e) {
      print('Error updating field: $e');
    }
    await removeItem(i);
  }

  @override
  Widget build(BuildContext context) {
    print(userWhoSendRequest);
    return Container(
      padding: EdgeInsets.all(16.0),
      child: widget.connectionRequest.isNotEmpty
          ? ListView.builder(
              itemCount: widget.connectionRequest.length,
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
                        IconButton(
                          onPressed: () {
                            acceptRequest(index);
                          },
                          icon: const Icon(Icons.add_box_outlined,
                              color: Colors.blue, size: 28),
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
                          child: Text(widget.connectionRequest[index]['user']
                              .toString()
                              .toUpperCase()
                              .substring(0, 1))),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(widget.connectionRequest[index]['user']),
                    ],
                  ),
                );
              },
            )
          : SizedBox(),
    );
  }
}
