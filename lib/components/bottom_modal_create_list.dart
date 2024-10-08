// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/popup_connections.dart';
import 'package:shoppinglist/services/theme_provider.dart';
import 'package:uuid/uuid.dart';

class BottomModalCreateList extends StatefulWidget {
  final VoidCallback onListCreated;
  final String displayName;
  const BottomModalCreateList(
      {super.key, required this.onListCreated, required this.displayName});

  @override
  State<BottomModalCreateList> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModalCreateList> {
  final TextEditingController listTitle = TextEditingController();
  bool warning = false;
  Timer? _warningTimer;
  final List<Map<String, String>> selectedUIDs = [];

  @override
  void dispose() {
    listTitle.dispose();
    _warningTimer?.cancel();
    super.dispose();
  }

  void createList() async {
    final User? user = Provider.of<User?>(context, listen: false);
    final String email = user?.email ?? "";
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    selectedUIDs.add({'id': user!.uid, 'name': widget.displayName});
    // Prepare the list data
    var day = DateTime.now().day < 10
        ? "0${DateTime.now().day}"
        : "${DateTime.now().day}";
    var month = DateTime.now().month < 10
        ? "0${DateTime.now().month}"
        : "${DateTime.now().month}";
    var date = "$day/$month/${DateTime.now().year}";

    final docData = {
      "creator": widget.displayName,
      "title": listTitle.text,
      "list": [],
      "date": date,
      "finished": false,
      "sharedWith": selectedUIDs,
      "listId": const Uuid().v4()
    };

    // Ensure the list has a title and email is available
    if (email.isNotEmpty && listTitle.text.isNotEmpty) {
      try {
        // Create the list for each selected user
        for (var uidMap in selectedUIDs) {
          String uid = uidMap['id']!;
          DocumentReference userDocRef;
          if (uid != user.uid) {
            userDocRef = firestore
                .collection("users")
                .doc(uid)
                .collection("pendingLists")
                .doc();
          } else {
            userDocRef = firestore
                .collection("users")
                .doc(uid)
                .collection("lists")
                .doc();
          }

          await userDocRef.set(docData);
        }
        Navigator.pop(context);
        widget.onListCreated();
        listTitle.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create list.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        warning = true;
      });
      _warningTimer?.cancel();
      _warningTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          warning = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    double screenHeight = MediaQuery.of(context).size.height;
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;
    final Color selectedColor =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
            ? Colors.white
            : themeColor;
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: isKeyboardVisible ? screenHeight / 2 + 150 : null,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        PopupConnections()
                            .showAlertDialog(context, selectedUIDs, themeColor);
                      },
                      icon: Icon(
                        Icons.people,
                        color: selectedColor,
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
                Text(
                  'רשימה חדשה',
                  style: TextStyle(
                    color: selectedColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
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
                          hintStyle: TextStyle(
                              color: selectedColor,
                              fontWeight: FontWeight.bold),
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
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'בטל',
                    style: TextStyle(
                        color: selectedColor, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: createList,
                  child: Text(
                    'צור רשימה',
                    style: TextStyle(
                        color: selectedColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
