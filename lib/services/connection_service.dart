import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionService {
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
      print("Error fetching connections: $e");
    }

    return connections;
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

        print("Connection removed successfully.");
      }
    } catch (e) {
      print("Error deleting connection: $e");
    }
  }
}
