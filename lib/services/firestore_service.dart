import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getUserDisplayName(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      return doc.get('displayName') as String?;
    } catch (e) {
      //print('Error getting display name: $e');
      return null;
    }
  }
}
