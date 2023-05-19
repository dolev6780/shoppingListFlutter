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
  List sendConnections = [];
  List connectionRequests = [];
  List userConnectionRequests = [];
  String? _userEmail = "";
  bool alreadySendRequest = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    users = [];
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').get();
      snapshot.docs.forEach((doc) {
        if (_auth.currentUser?.uid != doc.id) {
          users.add({"email": doc.data()['email']});
        }
      });
    } catch (e) {
      // Handle the error appropriately, e.g., show an error message
      print('Error fetching users: $e');
    }
    return users;
  }

  Future<List> getUserSendConnections() async {
    sendConnections = [];
    try {
      var docRef = _firestore.collection('users').doc(_auth.currentUser?.uid);
      await docRef.get().then((doc) {
        sendConnections.addAll(doc.data()?['sendconnections']);
      });
    } catch (e) {
      print('Error fetching sendconnections: $e');
    }
    return sendConnections;
  }

  Future<List> getUserConnectionRequests() async {
    userConnectionRequests = [];
    try {
      var docRef = _firestore.collection('users').doc(_auth.currentUser?.uid);
      await docRef.get().then((doc) {
        userConnectionRequests.addAll(doc.data()?['connectionsrequests']);
      });
    } catch (e) {
      print('Error fetching userConnectionRequests: $e');
    }
    return userConnectionRequests;
  }

  Future<List> getUserToSendConnectionRequests(id) async {
    connectionRequests = [];
    try {
      var docRef = _firestore.collection('users').doc(id);
      await docRef.get().then((doc) {
        connectionRequests.addAll(doc.data()?['connectionsrequests']);
      });
    } catch (e) {
      print('Error fetching connectionsrequests: $e');
    }
    return connectionRequests;
  }

  void searchUser(email) async {
    for (var i = 0; i < users.length; i++) {
      if (email == users[i]['email']) {
        setState(() {
          _userEmail = users[i]['email'];
        });
        break;
      }
    }

    await getUserSendConnections();
    for (var i = 0; i < sendConnections.length; i++) {
      if (email == sendConnections[i]['user']) {
        setState(() {
          alreadySendRequest = true;
        });
        break;
      } else {
        setState(() {
          alreadySendRequest = false;
        });
      }
    }

    await getUserConnectionRequests();
    for (var i = 0; i < userConnectionRequests.length; i++) {
      if (email == userConnectionRequests[i]['user']) {
        setState(() {
          alreadySendRequest = true;
        });
        break;
      } else {
        setState(() {
          alreadySendRequest = false;
        });
      }
    }
    if (_userEmail == "") {
      setState(() {
        _userEmail = "email is not valid";
      });
    }
  }

  Future<void> sendConnection() async {
    Map<String, dynamic> userToSendData = {};
    Map<String, dynamic> userData = {
      'user': _auth.currentUser?.email,
      'id': _auth.currentUser?.uid
    };

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').get();
      snapshot.docs.forEach((doc) async {
        if (_userEmail == doc.data()['email']) {
          userToSendData = {'user': _userEmail, 'id': doc.id};
          sendConnections.add(userToSendData);
          await getUserToSendConnectionRequests(userToSendData['id']);
          connectionRequests.add(userData);
        }
      });

      print('send');
      print(sendConnections);

      var saveDocRef =
          _firestore.collection('users').doc(_auth.currentUser?.uid);
      await saveDocRef.update({'sendconnections': sendConnections});

      var sendDocRef = _firestore.collection('users').doc(userToSendData['id']);
      print('send2');
      print(connectionRequests);
      await sendDocRef.update({'connectionsrequests': connectionRequests});

      setState(() {
        alreadySendRequest = true;
      });
    } catch (e) {
      // Handle the error appropriately, e.g., show an error message
      print('Error sending connection: $e');
    }
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
                      ElevatedButton(
                          onPressed: () {
                            searchUser(searchController.text);
                          },
                          child: Text("חפש")),
                      _userEmail!.isNotEmpty
                          ? _userEmail == "email is not valid"
                              ? Text(_userEmail.toString())
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: alreadySendRequest
                                                ? MaterialStateProperty.all<
                                                    Color>(Colors.grey)
                                                : MaterialStateProperty.all<
                                                    Color>(Colors.blue),
                                          ),
                                          onPressed: () {
                                            alreadySendRequest
                                                ? null
                                                : sendConnection();
                                          },
                                          child: Text("שלח בקשה")),
                                      Row(
                                        children: [
                                          Text(_userEmail.toString()),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          CircleAvatar(
                                              child: Text(_userEmail!
                                                  .substring(0, 1)
                                                  .toUpperCase()))
                                        ],
                                      )
                                    ],
                                  ),
                                )
                          : Text(""),
                    ],
                  )
                : Text('No users found');
          }
        },
      ),
    );
  }
}
