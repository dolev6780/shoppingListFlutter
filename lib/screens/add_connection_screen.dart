// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/app_bar.dart';

class AddConnectionScreen extends StatefulWidget {
  const AddConnectionScreen({Key? key}) : super(key: key);

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  ////// still need to refresh screen for the data will update in other screens///
////// instead disable button when request already sent myabe change to undo button///
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // initial lists for current user and user to send request////
  List<Map<String, dynamic>> users = [];
  List sendConnections = [];
  List userToSendConnectionRequests = [];
  List userConnectionRequests = [];

  //user to send email indicator ////
  String? _userEmail = "";
  /* if there is already send request from both side the
   flag pop and disable the button to send request*/
  bool alreadySendRequest = false;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

//future function to get all users for search purpose////
  Future<List<Map<String, dynamic>>> getUsers() async {
    users = [];
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').get();
      for (var doc in snapshot.docs) {
        if (doc.exists) {
          if (_auth.currentUser?.uid != doc.id) {
            users.add({"email": doc.data()['email']});
          }
        }
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
    return users;
  }

  // future function to get the current user send connections list from database////
  Future<List> getUserSendConnections() async {
    sendConnections = [];
    try {
      var docRef = _firestore.collection('users').doc(_auth.currentUser?.uid);
      await docRef.get().then((doc) {
        if (doc.exists) {
          sendConnections.addAll(doc.data()?['sendconnections']);
        }
      });
    } catch (e) {
      print('Error fetching sendconnections: $e');
    }
    return sendConnections;
  }

// future function to get the current user connection requests list from database////
  Future<List> getUserConnectionRequests() async {
    userConnectionRequests = [];
    try {
      var docRef = _firestore.collection('users').doc(_auth.currentUser?.uid);
      await docRef.get().then((doc) {
        if (doc.exists) {
          userConnectionRequests.addAll(doc.data()?['connectionsrequests']);
        }
      });
    } catch (e) {
      print('Error fetching userConnectionRequests: $e');
    }
    return userConnectionRequests;
  }

// future function to get the user to send connection requests list from database////
  Future<List> getUserToSendConnectionRequests(id) async {
    userToSendConnectionRequests = [];
    try {
      var docRef = _firestore.collection('users').doc(id);
      await docRef.get().then((doc) {
        if (doc.exists) {
          userToSendConnectionRequests
              .addAll(doc.data()?['connectionsrequests']);
        }
      });
    } catch (e) {
      print('Error fetching connectionsrequests: $e');
    }
    return userToSendConnectionRequests;
  }

// function to see if user to send is exist and if exist check //alreadySendRequest variable//////
  void searchUser(email) async {
    bool flag = true;
    for (var i = 0; i < users.length; i++) {
      if (email == users[i]['email']) {
        setState(() {
          _userEmail = users[i]['email'];
        });
        flag = true;
        break;
      } else {
        flag = false;
      }
    }
    if (_userEmail == "" || !flag) {
      setState(() {
        _userEmail = "email is not valid";
      });
      return;
    }
    await getUserSendConnections();
    print(sendConnections);
    for (var i = 0; i < sendConnections.length; i++) {
      if (email == sendConnections[i]['user']) {
        setState(() {
          alreadySendRequest = true;
        });
        return;
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
        return;
      } else {
        setState(() {
          alreadySendRequest = false;
        });
      }
    }
  }

//future function to send connection and update both current user and user to send database////
  Future<void> sendConnection() async {
    Map<String, dynamic> userToSendData = {};
    Map<String, dynamic> userData = {
      'user': _auth.currentUser?.email,
      'id': _auth.currentUser?.uid,
      'nickName': ""
    };

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').get();
      // ignore: avoid_function_literals_in_foreach_calls
      snapshot.docs.forEach((doc) async {
        if (doc.exists) {
          if (_userEmail == doc.data()['email']) {
            userToSendData = {'user': _userEmail, 'id': doc.id, 'nickName': ""};
            sendConnections.add(userToSendData);
            await getUserToSendConnectionRequests(userToSendData['id']);
            userToSendConnectionRequests.add(userData);
          }
        }
      });

      var userDocRef =
          _firestore.collection('users').doc(_auth.currentUser?.uid);
      await userDocRef.update({'sendconnections': sendConnections});

      var userToSendDocRef =
          _firestore.collection('users').doc(userToSendData['id']);
      await userToSendDocRef
          .update({'connectionsrequests': userToSendConnectionRequests});
      setState(() {
        alreadySendRequest = true;
      });
    } catch (e) {
      print('Error sending connection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Appbar(
            title: "הוספת איש קשר",
            backBtn: true,
            color: Color.fromARGB(255, 20, 67, 117),
          )),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                              borderSide: const BorderSide(
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
                          child: const Text("חפש")),
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
                                          child: const Text("שלח בקשה")),
                                      Row(
                                        children: [
                                          Text(_userEmail.toString()),
                                          const SizedBox(
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
                          : const Text(""),
                    ],
                  )
                : const Text('No users found');
          }
        },
      ),
    );
  }
}
