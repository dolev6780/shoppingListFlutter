import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomModalAddConnection extends StatefulWidget {
  const BottomModalAddConnection({super.key});

  @override
  State<BottomModalAddConnection> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModalAddConnection> {
  final Color _currentColor = const Color.fromARGB(255, 20, 67, 117);
  final TextEditingController connectionIdController = TextEditingController();
  Map<String, dynamic>? foundUser; // Store user data including doc ID
  String? foundUserId; // Store the document ID

  Future<void> searchUserByConnectionId(String connectionId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('connectId', isEqualTo: connectionId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot userDoc = querySnapshot.docs.first;
        setState(() {
          foundUser = userDoc.data() as Map<String, dynamic>?;
          foundUserId = userDoc.id;
        });
      } else {
        setState(() {
          foundUser = null;
          foundUserId = null;
        });
        print('No user found with connectionId $connectionId');
      }
    } catch (e) {
      print('Error searching user by connectionId: $e');
      setState(() {
        foundUser = null;
        foundUserId = null;
      });
    }
  }

  Future<void> addConnection(String foundUserId, String currentUserId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final currentUserRef = firestore.collection('users').doc(currentUserId);
    final foundUserRef = firestore.collection('users').doc(foundUserId);

    try {
      await firestore.runTransaction((transaction) async {
        final currentUserSnapshot = await transaction.get(currentUserRef);
        final foundUserSnapshot = await transaction.get(foundUserRef);

        if (currentUserSnapshot.exists && foundUserSnapshot.exists) {
          List<dynamic> currentUserConnections =
              currentUserSnapshot.data()?['connections'] ?? [];
          List<dynamic> foundUserConnections =
              foundUserSnapshot.data()?['connections'] ?? [];

          // Add the found user to current user's connections if not already present
          if (!currentUserConnections.contains(foundUserId)) {
            currentUserConnections.add(foundUserId);
          }

          // Add the current user to found user's connections if not already present
          if (!foundUserConnections.contains(currentUserId)) {
            foundUserConnections.add(currentUserId);
          }
          // Update both documents
          transaction
              .update(currentUserRef, {'connections': currentUserConnections});
          transaction
              .update(foundUserRef, {'connections': foundUserConnections});
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connection added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding connection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to add connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    double screenHeight = MediaQuery.of(context).size.height;
    Color selectedColor = _currentColor;
    final User? user = Provider.of<User?>(context, listen: false);

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: isKeyboardVisible ? screenHeight / 2 + 100 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'הוסף איש קשר',
              style: TextStyle(
                color: selectedColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: connectionIdController,
                      decoration: InputDecoration(
                        hintText: "מזהה איש קשר",
                        hintStyle: TextStyle(
                            color: selectedColor, fontWeight: FontWeight.bold),
                        labelStyle: TextStyle(color: selectedColor),
                        floatingLabelStyle: TextStyle(color: selectedColor),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: selectedColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: selectedColor),
                        ),
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(color: selectedColor),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => {connectionIdController.clear()},
                  child: Text(
                    'נקה',
                    style: TextStyle(
                        color: selectedColor, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final connectionId = connectionIdController.text.trim();
                    if (connectionId.isNotEmpty) {
                      await searchUserByConnectionId(connectionId);
                    } else {
                      print('Please enter a connection ID');
                    }
                  },
                  child: Text(
                    'חפש',
                    style: TextStyle(
                        color: selectedColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (foundUser != null)
              foundUser!['email'] != user!.email
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: ListTile(
                          title: Text(
                            '${foundUser!['displayName']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _currentColor,
                            child: Text(
                              foundUser!['displayName'][0]
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              if (user != null) {
                                addConnection(foundUserId!, user.uid);
                              }
                            },
                            icon: Icon(
                              Icons.add,
                              color: selectedColor,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Text("המזהה הוא שלך"),
            if (foundUser == null && connectionIdController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No user found with the given connection ID.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
