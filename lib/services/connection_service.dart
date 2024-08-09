import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchConnections() async {
    List<String> connectionIds = [];

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Fetch the user's document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // Check if the document exists
        if (userDoc.exists) {
          // Cast userDoc.data() to Map<String, dynamic>
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

          // Extract connection IDs
          connectionIds = List<String>.from(data?['connections'] ?? []);
        }
      }
    } catch (e) {
      print("Error fetching connections: $e");
    }

    return connectionIds;
  }
}
