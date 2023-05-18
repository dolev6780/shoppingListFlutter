import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/AddConnection.dart';
import 'package:shoppinglist/screens/ConnectionRequestsList.dart';

import '../components/MyConnectionsList.dart';

class MyConnections extends StatefulWidget {
  const MyConnections({Key? key});

  @override
  State<MyConnections> createState() => _MyConnectionsState();
}

class _MyConnectionsState extends State<MyConnections>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var data;
  List myConnections = [];
  List connectionRequest = [];
  List sendConnections = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    getConnectionLists();
  }

  void getConnectionLists() async {
    myConnections = [];
    connectionRequest = [];
    sendConnections = [];

    if (_auth.currentUser != null) {
      var collectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);

      await collectionRef.get().then(
        (doc) {
          if (doc.exists) {
            setState(() {
              myConnections.addAll(doc.data()?['connections'] ?? []);
              connectionRequest
                  .addAll(doc.data()?['connectionsrequests'] ?? []);
              sendConnections.addAll(doc.data()?['sendconnections'] ?? []);
            });
            print(myConnections);
            print(connectionRequest);
            print(sendConnections);
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('אנשי הקשר שלי'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.input),
              text: 'בקשות',
            ),
            Tab(
              icon: Icon(Icons.contacts),
              text: 'אנשי הקשר שלי',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          NestedTabBar(
              connectionRequest: connectionRequest,
              sendConnections: sendConnections),
          Center(
            child: MyConnectionsList(myConnections: myConnections),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => AddConnection(),
            ),
          );
        },
        label: Text("הוסף איש קשר"),
      ),
    );
  }
}

class NestedTabBar extends StatefulWidget {
  final List connectionRequest;
  final List sendConnections;
  const NestedTabBar(
      {super.key,
      required this.connectionRequest,
      required this.sendConnections});
  @override
  State<NestedTabBar> createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
                child: Text(
              'בקשות שהתקבלו',
              style: TextStyle(color: Colors.black),
            )),
            Tab(
                child: Text(
              'בקשות שנשלחו',
              style: TextStyle(color: Colors.black),
            )),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Card(
                child: ConnectionRequestsList(
                    connectionRequest: widget.connectionRequest),
              ),
              Card(
                child: MyConnectionsList(myConnections: widget.sendConnections),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
