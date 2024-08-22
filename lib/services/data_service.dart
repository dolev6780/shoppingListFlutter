import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchConnections() async {
    List<Map<String, dynamic>> connections = [];

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Fetch user's document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // Check if document exists
        if (userDoc.exists) {
          // Cast userDoc.data() to Map<String, dynamic>
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey('connections')) {
            // Extract connections as a List of Maps
            List<dynamic> rawConnections = data['connections'] ?? [];
            connections = rawConnections
                .map((conn) => Map<String, dynamic>.from(conn))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching connections: $e");
    }

    return connections;
  }

  Future<List<Map<String, dynamic>>> fetchSharedUsers(
      List<dynamic> sharedWith) async {
    List<Map<String, dynamic>> users = [];

    try {
      // Fetch details for each user in the sharedWith list
      for (var userId in sharedWith) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          // Cast userDoc.data() to Map<String, dynamic>
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            // Add the user's data to the list
            users.add({
              'name': userData[
                  'displayName'], // Assuming the user document has a 'name' field
              'email': userData['email'], // Add more fields if needed
              // Add other fields you need
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }

    return users;
  }

  Future<void> deleteConnection(String connectionId) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Reference to the current user's document
        DocumentReference userDocRef =
            _firestore.collection('users').doc(user.uid);

        // Run transaction to safely remove the connection
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot userDoc = await transaction.get(userDocRef);

          if (userDoc.exists) {
            Map<String, dynamic>? data =
                userDoc.data() as Map<String, dynamic>?;

            if (data != null && data.containsKey('connections')) {
              List<dynamic> connections = data['connections'] ?? [];

              // Remove the connection with the given ID
              connections.removeWhere((conn) => conn['id'] == connectionId);

              // Update the user's connections in Firestore
              transaction.update(userDocRef, {'connections': connections});
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error deleting connection: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchListTitles() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    try {
      var subCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lists');

      var querySnapshot = await subCollectionRef.get();

      return querySnapshot.docs
          .where((doc) => doc.data()['finished'] == false)
          .map((doc) => {
                'type': 'list',
                'color': doc.data()['color'],
                'creator': doc.data()['creator'],
                'date': doc.data()['date'],
                'finished': doc.data()['finished'],
                'list': doc.data()['list'],
                'listId': doc.data()['listId'],
                'sharedWith': doc.data()['sharedWith'],
                'title': doc.data()['title'],
                'docId': doc.id,
              })
          .toList();
    } catch (e) {
      debugPrint('Error fetching list titles: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPendingListTitles() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    try {
      var subCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pendingLists');

      var querySnapshot = await subCollectionRef.get();

      return querySnapshot.docs
          .map((doc) => {
                'type': 'pending',
                'creator': doc.data()['creator'] ?? 'Unknown',
                'date': doc.data()['date'] ?? 'No date',
                'finished': doc.data()['finished'] ?? false,
                'list': doc.data()['list'] ?? [],
                'listId': doc.data()['listId'] ?? "",
                'sharedWith': doc.data()['sharedWith'] ?? "",
                'title': doc.data()['title'] ?? 'Untitled',
                'docId': doc.id,
              })
          .toList();
    } catch (e) {
      debugPrint('Error fetching pending list titles: $e');
      return [];
    }
  }

  Future<void> deleteList(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc(docId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting list: $e');
    }
  }

  Future<void> deletePendingList(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pendingLists')
          .doc(docId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting pending list: $e');
    }
  }

  Future<void> approvePendingList(
      Map<String, dynamic> item, String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final docData = {
        "creator": item['creator'],
        "date": item['date'],
        "finished": item['finished'],
        "list": item['list'],
        "listId": item['listId'],
        "sharedWith": item['sharedWith'],
        "title": item['title'],
      };
      final DocumentReference newDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc();

      await newDocRef.set(docData);
      await deletePendingList(docId);
    } catch (e) {
      debugPrint('Error approving pending list: $e');
    }
  }
}
