import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditItem {
  final TextEditingController listItem = TextEditingController();
  bool warning = false;
  Timer? _warningTimer;

  void showAlertDialog(BuildContext context, Color color, String docId,
      VoidCallback onItemCreated, item, index) {
    Color selectedTextColor = color;

    if (item != null) {
      listItem.text = item;
    }
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              elevation: 8,
              backgroundColor: Colors.white,
              actionsAlignment: MainAxisAlignment.center,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      item == null ? 'צור משימה' : 'ערוך משימה',
                      style: TextStyle(
                          color: selectedTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    ),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.all(8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: SizedBox(
                      width: 300,
                      height: 30,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: listItem,
                          decoration: InputDecoration(
                            hintText: "מה המשימה?",
                            hintStyle: TextStyle(color: selectedTextColor),
                            labelStyle: TextStyle(color: selectedTextColor),
                            floatingLabelStyle:
                                TextStyle(color: selectedTextColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: selectedTextColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: selectedTextColor),
                            ),
                          ),
                          textAlign: TextAlign.right,
                          style: TextStyle(color: selectedTextColor),
                        ),
                      ),
                    ),
                  ),
                  warning
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              transform: Matrix4.translationValues(
                                warning ? 1 : 0.0,
                                0.0,
                                0.0,
                              ),
                              child: const Text(
                                "יש להקליד משימה",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 0),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: Text(
                    'בטל',
                    style: TextStyle(
                        color: selectedTextColor, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    updateItemsInList(
                        context, setState, docId, onItemCreated, index);
                  },
                  child: Text(
                    item == null ? 'צור משימה' : 'ערוך משימה',
                    style: TextStyle(
                        color: selectedTextColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateItemsInList(BuildContext context, StateSetter setState,
      String docId, VoidCallback onItemCreated, int index) async {
    final User? user = Provider.of<User?>(context, listen: false);
    var time = "${DateTime.now().hour + 3}:${DateTime.now().minute}";
    try {
      var docRef =
          FirebaseFirestore.instance.collection('users').doc("${user?.uid}");
      var subcollectionRef = docRef.collection('lists');
      var documentSnapshot = await subcollectionRef.doc(docId).get();
      List<dynamic> list = documentSnapshot.data()?['list'] ?? [];
      list[index]['item'] = listItem.text;
      list[index]['time'] = time;
      await subcollectionRef.doc(docId).update({'list': list});
      onItemCreated();
      listItem.text = "";
      Navigator.pop(context, 'OK');
    } catch (e) {
      print('Error updating subcollection field: $e');
    }
  }

  void editItemInList(BuildContext context, StateSetter setState, String docId,
      VoidCallback onItemCreated, int index) async {
    final User? user = Provider.of<User?>(context, listen: false);
    var time = "${DateTime.now().hour + 3}:${DateTime.now().minute}";
    try {
      if (listItem.text.isEmpty) {
        setState(() {
          warning = true;
        });
        _warningTimer?.cancel();
        _warningTimer = Timer(const Duration(seconds: 5), () {
          setState(() {
            warning = false;
          });
        });
        return;
      }
      var docRef =
          FirebaseFirestore.instance.collection('users').doc("${user?.uid}");
      var subcollectionRef = docRef.collection('lists');
      var documentSnapshot = await subcollectionRef.doc(docId).get();
      List<dynamic> list = documentSnapshot.data()?['list'] ?? [];
      list[index] = {
        'item': listItem.text,
        'time': time,
        'checked': list[index]['checked']
      };
      await subcollectionRef.doc(docId).update({'list': list});
      onItemCreated();
      listItem.text = "";
      Navigator.pop(context, 'OK');
    } catch (e) {
      print('Error updating subcollection field: $e');
    }
  }
}
