// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditItem {
  final TextEditingController listItem = TextEditingController();
  bool warning = false;

  void showAlertDialog(BuildContext context, Color color, String docId,
      VoidCallback onItemCreated, item, index, sharedWith, listId) {
    Color selectedTextColor = color;

    if (item != null) {
      listItem.text = item;
    }
    List<dynamic> sharedWithList = sharedWith;
    List<String> ids = sharedWithList
        .where((item) => item is Map<String, dynamic> && item['id'] is String)
        .map((item) => item['id'] as String)
        .toList();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              elevation: 8,
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
                    updateItemsInList(context, setState, docId, onItemCreated,
                        index, ids, listId);
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

  void updateItemsInList(
      BuildContext context,
      StateSetter setState,
      String docId,
      VoidCallback onItemCreated,
      int index,
      List<String> ids,
      String listId) async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("users");
    var time = "${DateTime.now().hour + 3}:${DateTime.now().minute}";
    try {
      for (String sharedUserId in ids) {
        // Query and update documents in 'lists' collection
        final QuerySnapshot listsSnapshot = await collectionRef
            .doc(sharedUserId)
            .collection("lists")
            .where("listId", isEqualTo: listId)
            .get();

        for (var doc in listsSnapshot.docs) {
          List<dynamic> list = doc['list'] ?? [];
          list[index]['item'] = listItem.text;
          list[index]['time'] = time;
          await doc.reference.update({'list': list});
        }

        // Query and update documents in 'pendingLists' collection
        final QuerySnapshot pendingListsSnapshot = await collectionRef
            .doc(sharedUserId)
            .collection("pendingLists")
            .where("listId", isEqualTo: listId)
            .get();

        for (var doc in pendingListsSnapshot.docs) {
          List<dynamic> list = doc['list'] ?? [];
          list[index]['item'] = listItem.text;
          list[index]['time'] = time;
          await doc.reference.update({'list': list});
        }
      }
      onItemCreated();
      listItem.text = "";
      Navigator.pop(context, 'OK');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item: $e'),
        ),
      );
    }
  }
}
