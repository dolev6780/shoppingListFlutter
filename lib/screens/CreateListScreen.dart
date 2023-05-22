import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/screens/HomeScreen.dart';
import '../components/TextInput.dart';

class CreateListScreen extends StatefulWidget {
  const CreateListScreen({Key? key}) : super(key: key);

  @override
  State<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    connections.add({'nickName': "לעצמי", 'user': _email, 'id': _user?.uid});
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
          collectionRef.doc("${selectedOption}").collection("shoplists").doc();
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
          await userDestinedDocRef.set(docData);
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text("יצירת רשימה חדשה"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 5, 15, 5),
                  decoration: BoxDecoration(
                      border: Border.all(
                          style: BorderStyle.solid, color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
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
                                    : Text(value['user'].toString()),
                              ));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value as String?;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
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
                      child: TextButton(
                        onPressed: () {
                          item();
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text('הוסף'),
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
                          color: Colors.black,
                          width: 1.0,
                          style: BorderStyle.solid)),
                  height: 230,
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
                            return ListTile(
                              leading: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        removeItem(index);
                                      },
                                      icon: const Icon(Icons.delete),
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
                                      child:
                                          Text(shopList[index].qty.toString())),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    shopList[index].item,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    createList();
                  },
                  child: const Text(
                    'צור רשימה',
                    style: TextStyle(fontSize: 18),
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
