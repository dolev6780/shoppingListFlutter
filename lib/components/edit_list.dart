// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/popup_update_connections.dart';
import 'package:shoppinglist/screens/home_screen.dart';

class EditList {
  final Color _currentColor;
  final TextEditingController listTitle;
  bool _listTitleWarning = false;
  Timer? _warningTimer;
  final String listId;
  final List sharedWith;
  EditList({
    required this.listId,
    required String initialTitle,
    required Color initialColor,
    required this.sharedWith,
  })  : _currentColor = initialColor,
        listTitle = TextEditingController(text: initialTitle);
  void showAlertDialog(BuildContext context) {
    Color selectedColor = _currentColor;

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              elevation: 8,
              actionsAlignment: MainAxisAlignment.center,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      PopupUpdateConnections()
                          .showAlertDialog(context, sharedWith, _currentColor);
                    },
                    icon: Icon(
                      Icons.group_add,
                      color: selectedColor,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'ערוך רשימה',
                      style: TextStyle(
                          color: selectedColor,
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
                          controller: listTitle,
                          decoration: InputDecoration(
                            hintText: "שם הרשימה",
                            hintStyle: TextStyle(color: selectedColor),
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
                  ),
                  _listTitleWarning
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              transform: Matrix4.translationValues(
                                _listTitleWarning ? 1 : 0.0,
                                0.0,
                                0.0,
                              ),
                              child: const Text(
                                "יש להקליד שם לרשימה",
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
                        color: selectedColor, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    editList(context, setState);
                  },
                  child: Text(
                    'עדכן רשימה',
                    style: TextStyle(
                        color: selectedColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void editList(BuildContext context, StateSetter setState) async {
    final User? user = Provider.of<User?>(context, listen: false);
    final String email = user != null ? user.email.toString() : " ";

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference collectionRef = firestore.collection("users");
    final DocumentSnapshot documentSnapshot =
        await firestore.collection('users').doc(user!.uid).get();
    final name = documentSnapshot['displayName'];
    var day = DateTime.now().day < 10
        ? "0${DateTime.now().day}"
        : "${DateTime.now().day}";
    var month = DateTime.now().month < 10
        ? "0${DateTime.now().month}"
        : "${DateTime.now().month}";
    var date = "$day/$month/${DateTime.now().year}";
    String currentColorHex =
        '#${_currentColor.value.toRadixString(16).substring(2)}';
    final docData = {
      "creator": name,
      "title": listTitle.text,
      "date": date,
      "color": currentColorHex,
      "sharedWith": sharedWith,
      "listId": listId
    };
    if (email.isNotEmpty && listTitle.text.isNotEmpty) {
      try {
        // Retrieve the list of users who have access to this list
        for (var uidMap in sharedWith) {
          String uid = uidMap['id']!;
          DocumentReference userDocRef;
          if (uid != user.uid) {
            userDocRef = firestore
                .collection("users")
                .doc(uid)
                .collection("pendingLists")
                .doc();
            await userDocRef.set(docData);
          }
        }
        List<String> ids = sharedWith
            .where(
                (item) => item is Map<String, dynamic> && item['id'] is String)
            .map((item) => item['id'] as String)
            .toList();

        for (String sharedUserId in ids) {
          // Query and update documents in 'lists' collection
          final QuerySnapshot listsSnapshot = await collectionRef
              .doc(sharedUserId)
              .collection("lists")
              .where("listId", isEqualTo: listId)
              .get();

          for (var doc in listsSnapshot.docs) {
            await doc.reference.update(docData);
          }

          // Query and update documents in 'pendingLists' collection
          final QuerySnapshot pendingListsSnapshot = await collectionRef
              .doc(sharedUserId)
              .collection("pendingLists")
              .where("listId", isEqualTo: listId)
              .get();

          for (var doc in pendingListsSnapshot.docs) {
            await doc.reference.update(docData);
          }
        }

        // Navigate back to the HomeScreen
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update list: $e'),
          ),
        );
      }
    } else {
      setState(() {
        _listTitleWarning = true;
      });
      _warningTimer?.cancel();
      _warningTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          _listTitleWarning = false;
        });
      });
    }
  }
}
