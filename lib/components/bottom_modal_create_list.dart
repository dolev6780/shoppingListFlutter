import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomModalCreateList extends StatefulWidget {
  final VoidCallback onListCreated;

  const BottomModalCreateList({super.key, required this.onListCreated});

  @override
  State<BottomModalCreateList> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModalCreateList> {
  Color _currentColor = const Color.fromARGB(255, 20, 67, 117);
  bool _expanded = false;
  final TextEditingController listTitle = TextEditingController();
  bool warning = false;
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

  void createList() async {
    final User? user = Provider.of<User?>(context, listen: false);
    final String email = user?.email ?? "";
    List<Map<String, dynamic>> data = [];
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef = firestore
        .collection("users")
        .doc("${user?.uid}")
        .collection("lists")
        .doc();

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
      "creator": email,
      "title": listTitle.text,
      "list": data,
      "date": date,
      "finished": false,
      "color": currentColorHex,
    };

    if (email.isNotEmpty && listTitle.text.isNotEmpty) {
      try {
        await userDocRef.set(docData);
        Navigator.pop(context); // Close modal
        widget.onListCreated(); // Notify parent
      } catch (e) {
        print("Error creating list: $e");
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
    Color selectedColor = _currentColor;
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: isKeyboardVisible ? screenHeight / 2 + 100 : null,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'רשימה חדשה',
              style: TextStyle(
                  color: selectedColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
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
                              children: List.generate(_colors.length, (index) {
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
