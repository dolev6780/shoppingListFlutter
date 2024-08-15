import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomModalCreateItem extends StatefulWidget {
  final Color color;
  final String docId;
  final String listId;
  final List sharedWith;
  final VoidCallback onItemCreated;

  const BottomModalCreateItem(
      {super.key,
      required this.onItemCreated,
      required this.color,
      required this.docId,
      required this.listId,
      required this.sharedWith});

  @override
  State<BottomModalCreateItem> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModalCreateItem> {
  final TextEditingController listItem = TextEditingController();
  bool warning = false;
  Timer? _warningTimer;

  void updateItemsInList() async {
    Provider.of<User?>(context, listen: false);
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
      var docRef = FirebaseFirestore.instance.collection('users');
      List<String> sharedWithUsers = List<String>.from(widget.sharedWith);
      for (String sharedUserId in sharedWithUsers) {
        // Query and update documents in 'lists' collection
        final QuerySnapshot listsSnapshot = await docRef
            .doc(sharedUserId)
            .collection("lists")
            .where("listId", isEqualTo: widget.listId)
            .get();

        for (var doc in listsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            List<dynamic> list = data['list'] ?? [];
            list.add({'item': listItem.text, 'time': time, 'checked': false});
            await doc.reference.update({'list': list});
          }
        }

        // Query and update documents in 'pendingLists' collection
        final QuerySnapshot pendingListsSnapshot = await docRef
            .doc(sharedUserId)
            .collection("pendingLists")
            .where("listId", isEqualTo: widget.listId)
            .get();

        for (var doc in pendingListsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            List<dynamic> list = data['list'] ?? [];
            list.add({'item': listItem.text, 'time': time, 'checked': false});
            await doc.reference.update({'list': list});
          }
        }
      }
      widget.onItemCreated();
      listItem.text = "";
      Navigator.pop(context, 'OK');
    } catch (e) {
      print('Error updating subcollection field: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    double screenHeight = MediaQuery.of(context).size.height;

    Color selectedColor = widget.color;
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: isKeyboardVisible ? screenHeight / 2 + 50 : null,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'משימה חדשה',
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
                        controller: listItem,
                        decoration: InputDecoration(
                          hintText: "שם המשימה",
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
                              "יש להקליד שם משימה",
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
                  onPressed: updateItemsInList,
                  child: Text(
                    'צור משימה',
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
