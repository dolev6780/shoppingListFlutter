import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/screens/HomeScreen.dart';
import '../components/TextInput.dart';

class CreateListScreen extends StatefulWidget {
  const CreateListScreen({super.key});

  @override
  State<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _email = "";
  final TextEditingController listTitleController = TextEditingController();
  final TextEditingController listItemController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  int items = 0;
  List<Shoppinglist> shopList = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (!(_user?.email == null)) {
      _email = _user?.email;
    }
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
      List data = [];
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference collectionRef = firestore.collection("users");
      final DocumentReference newDocRef =
          collectionRef.doc("${_user?.uid}").collection("shoplists").doc();
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
        "title": listTitleController.text,
        "list": data,
        "date": date
      };
      if (_email?.isNotEmpty == true) {
        if (shopList.isNotEmpty) {
          await newDocRef.set(docData);
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const HomeScreen(),
              ));
        } else {
          print("list is empty");
        }
      } else {
        print("must sign");
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("יצירת רשימה חדשה ${_email!}"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
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
                  height: 285,
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
                                      icon: Icon(Icons.delete),
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
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(shopList[index].item),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("כמות פריטים: $items"),
                    const SizedBox(
                      width: 10,
                    ),
                    Text("כמות מוצרים: ${shopList.length}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            createList();
          },
          label: const Text("צור רשימה")),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class Shoppinglist {
  String item;
  int qty;

  Shoppinglist(this.item, this.qty);
}
