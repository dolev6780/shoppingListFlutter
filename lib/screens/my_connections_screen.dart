// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/add_connection_screen.dart';
import 'package:shoppinglist/components/connection_requests_list.dart';
import 'package:shoppinglist/components/send_connections_list.dart';
import 'package:shoppinglist/screens/finished_lists_screen.dart';
import 'package:shoppinglist/screens/home_screen.dart';
import '../components/bottom_navigation.dart';
import '../components/my_connections_list.dart';

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      var collectionRef =
          _firestore.collection('users').doc(_auth.currentUser!.uid);

      await collectionRef.get().then(
        (doc) {
          if (doc.exists) {
            setState(() {
              myConnections.addAll(doc.data()?['connections'] ?? []);
              connectionRequest
                  .addAll(doc.data()?['connectionsrequests'] ?? []);
              sendConnections.addAll(doc.data()?['sendconnections'] ?? []);
            });
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
  }

  int _currentIndex = 1;

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
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const FinishedListsScreen(),
            ));
        break;
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
      bottomNavigationBar: GradientBottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'עמוד הבית',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'אנשי הקשר שלי',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'היסטוריית רשימות',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const AddConnectionScreen(),
            ),
          );
        },
        label: const Text("הוסף איש קשר"),
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
                child: SendConnectionsList(
                    sendConnections: widget.sendConnections),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
