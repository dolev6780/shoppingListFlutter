// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/components/bottom_modal_add_connection.dart';

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List connections = [];

  @override
  void initState() {
    super.initState();

    getConnectionLists();
  }

  void getConnectionLists() async {
    connections = [];

    if (_auth.currentUser != null) {
      var collectionRef =
          _firestore.collection('users').doc(_auth.currentUser!.uid);

      await collectionRef.get().then(
        (doc) {
          if (doc.exists) {
            List<String> connectionIds =
                List<String>.from(doc.data()?['connections'] ?? []);
            if (connectionIds.isNotEmpty) {
              Future.wait(connectionIds.map((id) async {
                var userDoc =
                    await _firestore.collection('users').doc(id).get();
                if (userDoc.exists) {
                  var userData = userDoc.data();
                  if (userData != null) {
                    setState(() {
                      connections.add(userData);
                      print(connections);
                    });
                  }
                }
              })).then((_) {
                // Once all user data is fetched, you can update the state
                setState(() {});
              });
            }
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = const Color.fromARGB(255, 20, 67, 117);
    Color textColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(color: color),
        ),
        title: Text(
          'אנשי הקשר שלי',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: connections.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : ListView.builder(
              itemCount: connections.length,
              itemBuilder: (context, index) {
                var connection = connections[index];
                print(connection);
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 20, 67, 117),
                        child: Text(
                          connection['displayName'][0].toString().toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        connection['displayName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const BottomModalAddConnection(),
          );
        },
        label: const Text("הוסף איש קשר"),
      ),
    );
  }
}
