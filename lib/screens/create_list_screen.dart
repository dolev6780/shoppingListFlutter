// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/screens/home_screen.dart';
import '../components/app_bar.dart';
import '../components/text_input.dart';

class CreateListScreen extends StatefulWidget {
  const CreateListScreen({Key? key}) : super(key: key);

  @override
  State<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? _user;
  String? _email = "";
  final TextEditingController listTitleController = TextEditingController();
  final TextEditingController listItemController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  int items = 0;
  List<Shoppinglist> shopList = [];
  List connections = [];
  String? selectedOption;
  final List<DropdownMenuItem<dynamic>> options = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (!(_user?.email == null)) {
      _email = _user?.email;
    }

    getConnections().then((List result) {
      setState(() {
        connections = result;
        selectedOption =
            connections.isNotEmpty ? connections[0]['id'].toString() : null;
      });
    });
  }

  Future<List> getConnections() async {
    connections = [];
    connections.add({'nickName': "רק לעצמי", 'user': _email, 'id': _user?.uid});
    try {
      var docRef = await firestore.collection('users').doc(_user?.uid).get();
      if (docRef.exists) {
        if (docRef.data()?['connections'] != null) {
          connections.addAll(docRef.data()?['connections']);
        }
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
    print(connections);
    return connections;
  }

  @override
  Widget build(BuildContext context) {
    void item() {
      if (!(itemQtyController.text == "" || listItemController.text == "")) {
        setState(() {
          items += int.parse(itemQtyController.text);
          shopList.add(Shoppinglist(
              listItemController.text, int.parse(itemQtyController.text)));
        });
        setState(() {
          listItemController.clear();
          itemQtyController.clear();
        });
      } else {
        print("enter values");
      }
    }

    void removeItem(int i) {
      setState(() {
        items -= shopList[i].qty;
        shopList.removeAt(i);
      });
    }

    void createList() async {
      List<Map<String, dynamic>> data = [];
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference collectionRef = firestore.collection("users");
      final DocumentReference userDocRef =
          collectionRef.doc("${_user?.uid}").collection("shoplists").doc();
      final DocumentReference userDestinedDocRef =
          collectionRef.doc("$selectedOption").collection("shoplists").doc();
      for (var i = 0; i < shopList.length; i++) {
        data.add({
          'item': shopList[i].item,
          'qty': shopList[i].qty,
          'checked': false
        });
      }
      var day = DateTime.now().day < 10
          ? "0${DateTime.now().day}"
          : "${DateTime.now().day}";
      var month = DateTime.now().month < 10
          ? "0${DateTime.now().month}"
          : "${DateTime.now().month}";
      var date = "$day/$month/${DateTime.now().year}";

      final docData = {
        "creator": _email,
        "title": listTitleController.text,
        "list": data,
        "date": date,
        "finished": false
      };
      if (_email?.isNotEmpty == true) {
        if (shopList.isNotEmpty) {
          await userDocRef.set(docData);
          if (selectedOption != _user?.uid) {
            await userDestinedDocRef.set(docData);
          }
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const HomeScreen(),
              ));
        } else {
          print("list is empty");
        }
      } else {
        print("must sign in");
      }
    }

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Appbar(
            title: "יצירת רשימה חדשה",
            backBtn: true,
          )),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  decoration: BoxDecoration(
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: const Color.fromARGB(255, 8, 45, 114)),
                      borderRadius: BorderRadius.circular(10)),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        borderRadius: BorderRadius.circular(10),
                        icon: const Icon(Icons.share),
                        menuMaxHeight: 300,
                        value: selectedOption,
                        items:
                            connections.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                              value: value['id'].toString(),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: value['nickName'].toString().isNotEmpty
                                    ? Text(value['nickName'].toString())
                                    : Text(value['user'].toString().substring(0,
                                        value['user'].toString().indexOf("@"))),
                              ));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextInputWidget(
                  controller: listTitleController,
                  placeholder: 'שם הרשימה',
                  inputType: InputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 74, 167, 243),
                              Color.fromARGB(255, 22, 115, 228)
                            ], // List of colors for the gradient
                            begin: Alignment
                                .centerLeft, // Starting point of the gradient
                            end: Alignment
                                .centerRight, // Ending point of the gradient
                          ),
                          borderRadius: BorderRadius.circular(
                              10.0), // Optional border radius
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey, // Shadow color
                              offset: Offset(0,
                                  2), // Horizontal and vertical offset of the shadow
                              blurRadius: 4.0, // Spread radius of the shadow
                              spreadRadius:
                                  0.0, // Extent of the shadow (positive values expand the shadow, negative values shrink it)
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            item();
                            FocusScope.of(context).unfocus();
                          },
                          child: const Text('הוסף',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextInputWidget(
                        controller: itemQtyController,
                        placeholder: 'כמות',
                        inputType: InputType.number,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 3,
                      child: TextInputWidget(
                        controller: listItemController,
                        placeholder: 'פריט',
                        inputType: InputType.text,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Color.fromARGB(255, 28, 16, 199),
                          width: 1.0,
                          style: BorderStyle.solid)),
                  height: 250,
                  width: double.infinity,
                  child: shopList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "הוסף פריטים לרשימה",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        )
                      : ListView.builder(
                          itemCount: shopList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          removeItem(index);
                                        },
                                        icon: Icon(Icons.delete,
                                            color: Colors.blue[700]),
                                      ),
                                    ],
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                title: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    CircleAvatar(
                                        radius: 15,
                                        child: Text(
                                            shopList[index].qty.toString())),
                                    const SizedBox(width: 20.0),
                                    Text(
                                      shopList[index].item,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 74, 167, 243),
                        Color.fromARGB(255, 22, 115, 228)
                      ], // List of colors for the gradient
                      begin: Alignment
                          .centerLeft, // Starting point of the gradient
                      end:
                          Alignment.centerRight, // Ending point of the gradient
                    ),
                    borderRadius:
                        BorderRadius.circular(10.0), // Optional border radius
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey, // Shadow color
                        offset: Offset(0,
                            2), // Horizontal and vertical offset of the shadow
                        blurRadius: 4.0, // Spread radius of the shadow
                        spreadRadius:
                            0.0, // Extent of the shadow (positive values expand the shadow, negative values shrink it)
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      onPressed: () {
                        createList();
                      },
                      child: const Text(
                        'צור רשימה',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Shoppinglist {
  final String item;
  final int qty;

  Shoppinglist(this.item, this.qty);
}
