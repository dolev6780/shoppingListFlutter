import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/screens/home_screen.dart';

class EditList {
  Color _currentColor;
  Color _currentTextColor;
  bool _expanded = false;
  final TextEditingController listTitle;
  bool _listTitleWarning = false;
  Timer? _warningTimer;
  final List<Color> _colors = [
    const Color.fromARGB(255, 20, 67, 117),
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.tealAccent,
  ];

  final String listId;

  EditList({
    required this.listId,
    required String initialTitle,
    required Color initialColor,
    required Color initialTextColor,
  })  : _currentColor = initialColor,
        _currentTextColor = initialTextColor,
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
              backgroundColor: Colors.white,
              actionsAlignment: MainAxisAlignment.center,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Blank Popup'),
                            content: const Text('This is a blank popup.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
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
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: _expanded ? 220.0 : 24.0,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children:
                                    List.generate(_colors.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedColor = _colors[index];
                                        _currentColor = selectedColor;
                                      });
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: _colors[index],
                                        shape: BoxShape.circle,
                                        border: selectedColor == _colors[index]
                                            ? Border.all(
                                                color: Colors.black, width: 2.0)
                                            : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expanded = !_expanded;
                                });
                              },
                              child: !_expanded
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(158, 0, 0, 0),
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : Icon(
                                      Icons.close,
                                      color: selectedColor,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
    final DocumentReference userDocRef =
        collectionRef.doc("${user?.uid}").collection("lists").doc(listId);

    var day = DateTime.now().day < 10
        ? "0${DateTime.now().day}"
        : "${DateTime.now().day}";
    var month = DateTime.now().month < 10
        ? "0${DateTime.now().month}"
        : "${DateTime.now().month}";
    var date = "$day/$month/${DateTime.now().year}";
    String currentColorHex =
        '#${_currentColor.value.toRadixString(16).substring(2)}';
    String currentTextColorHex =
        '#${_currentTextColor.value.toRadixString(16).substring(2)}';
    final docData = {
      "creator": email,
      "title": listTitle.text,
      "date": date,
      "color": currentColorHex,
      "textColor": currentTextColorHex
    };

    if (email.isNotEmpty && listTitle.text.isNotEmpty) {
      try {
        await userDocRef.update(docData);

        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      } catch (e) {
        print("Error updating list: $e");
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
