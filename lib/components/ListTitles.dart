import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListTitles extends StatefulWidget {
  const ListTitles({Key? key}) : super(key: key);

  @override
  State<ListTitles> createState() => ListTitlesState();
}

class ListTitlesState extends State<ListTitles> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  List<Map<String, dynamic>> shopListTitles = [];
  List<bool> _isOpen = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    var subCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc("${_user?.uid}")
        .collection('shoplists');
    if (!(_user?.uid == null)) {
      subCollectionRef.snapshots().listen((querySnapshot) {
        List<Map<String, dynamic>> newShopListTitles = [];
        querySnapshot.docs.forEach((doc) {
          newShopListTitles
              .add({'title': doc.data()['title'], 'date': doc.data()['date']});
        });
        setState(() {
          shopListTitles = newShopListTitles;
          _isOpen =
              List<bool>.generate(shopListTitles.length, (index) => false);
        });
      });
    } else {
      shopListTitles = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: shopListTitles.isNotEmpty
            ? ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpen[index] = !isExpanded;
                  });
                },
                children: shopListTitles.map<ExpansionPanel>((data) {
                  int index = shopListTitles.indexOf(data);
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _isOpen[index] = !isExpanded;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              SizedBox(width: 16.0),
                              Text(
                                data['title'].toString(),
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    body: Text("data"),
                    isExpanded: _isOpen[index],
                  );
                }).toList(),
              )
            : SizedBox(),
      ),
    );
  }
}
