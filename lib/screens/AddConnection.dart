import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class AddConnection extends StatefulWidget {
  const AddConnection({Key? key}) : super(key: key);

  @override
  _AddConnectionState createState() => _AddConnectionState();
}

class _AddConnectionState extends State<AddConnection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> users = [];
  String? _userEmail;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    users = [];
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').get();
    snapshot.docs.forEach((doc) {
      if (_auth.currentUser?.uid != doc.id) {
        users.add({"email": doc.data()['email']});
      }
    });
    print(users);
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("הוספת איש קשר"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> users = snapshot.data!;
            return users.isNotEmpty
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: searchController,
                          maxLength: 20,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "הכנס אימייל",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(onPressed: () {}, child: Text("חפש"))
                    ],
                  )
                : Text('No users found');
          }
        },
      ),
    );
  }
}
