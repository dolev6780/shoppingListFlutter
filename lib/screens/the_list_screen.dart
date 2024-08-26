// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/components/bottom_modal_create_item.dart';
import 'package:shoppinglist/components/edit_item.dart';
import 'package:shoppinglist/components/overlap_circle_avatar.dart';
import 'package:shoppinglist/screens/home_screen.dart';
import '../components/app_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TheListScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color color;
  final String uid;

  const TheListScreen({
    Key? key,
    required this.item,
    required this.color,
    required this.uid,
  }) : super(key: key);

  @override
  State<TheListScreen> createState() => _TheListScreenState();
}

class _TheListScreenState extends State<TheListScreen> {
  List<dynamic> listItems = [];
  int checkedCount = 0;
  final EditItem _editItem = EditItem();
  @override
  void initState() {
    super.initState();
    refreshList();
  }

  Future<void> updateSubcollectionField() async {
    try {
      var docRef = FirebaseFirestore.instance.collection('users');
      List<dynamic> sharedWithUsers = widget.item['sharedWith'];

      List<String> ids = sharedWithUsers
          .where((item) => item is Map<String, dynamic> && item['id'] is String)
          .map((item) => item['id'] as String)
          .toList();
      for (String sharedUserId in ids) {
        // Query and update documents in 'lists' collection
        final QuerySnapshot listsSnapshot = await docRef
            .doc(sharedUserId)
            .collection("lists")
            .where("listId", isEqualTo: widget.item['listId'])
            .get();

        for (var doc in listsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            await doc.reference.update({'list': listItems});
          }
        }

        // Query and update documents in 'pendingLists' collection
        final QuerySnapshot pendingListsSnapshot = await docRef
            .doc(sharedUserId)
            .collection("pendingLists")
            .where("listId", isEqualTo: widget.item['listId'])
            .get();

        for (var doc in pendingListsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            await doc.reference.update({'list': listItems});
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update item in list.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> refreshList() async {
    try {
      var docRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);
      var subcollectionRef = docRef.collection('lists');
      var documentSnapshot =
          await subcollectionRef.doc(widget.item['docId']).get();
      setState(() {
        listItems = documentSnapshot.data()?['list'] ?? [];
        checkedCount =
            listItems.where((item) => item['checked'] == true).length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error refreshing list'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCheckboxChanged(bool? value, int index) {
    setState(() {
      listItems[index]['checked'] = value;
      checkedCount = listItems.where((item) => item['checked'] == true).length;
    });
    updateSubcollectionField();
  }

  Future<void> finishList() async {
    try {
      var docRef = FirebaseFirestore.instance.collection('users');
      List<dynamic> sharedWithUsers = widget.item['sharedWith'];

      List<String> ids = sharedWithUsers
          .where((item) => item is Map<String, dynamic> && item['id'] is String)
          .map((item) => item['id'] as String)
          .toList();

      for (String sharedUserId in ids) {
        // Query and update documents in 'lists' collection
        final QuerySnapshot listsSnapshot = await docRef
            .doc(sharedUserId)
            .collection("lists")
            .where("listId", isEqualTo: widget.item['listId'])
            .get();

        for (var doc in listsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            await doc.reference.update({'finished': true});
          }
        }

        // Query and update documents in 'pendingLists' collection
        final QuerySnapshot pendingListsSnapshot = await docRef
            .doc(sharedUserId)
            .collection("pendingLists")
            .where("listId", isEqualTo: widget.item['listId'])
            .get();

        for (var doc in pendingListsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            await doc.reference.update({'finished': true});
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('הרשימה הסתיימה'),
            backgroundColor: Colors.green,
          ),
        );
        Timer(
          const Duration(seconds: 2),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete the list.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteItem(index) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת פריט'),
        content: const Text('האם אתה בטוח שתרצה למחוק את הפריט?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'בטל',
              style: TextStyle(color: widget.color),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'אשר',
              style: TextStyle(color: widget.color),
            ),
          ),
        ],
      ),
    );
    if (confirmDelete == true) {
      setState(() {
        listItems.removeAt(index);
        checkedCount =
            listItems.where((item) => item['checked'] == true).length;
      });
      await updateSubcollectionField();
    }
  }

  final GlobalKey _toolTipKey = GlobalKey();

  void _showTooltip() {
    final dynamic tooltip = _toolTipKey.currentState;
    tooltip.ensureTooltipVisible();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> sharedWith = widget.item['sharedWith'];
    List<String> names = sharedWith
        .where((item) => item is Map<String, dynamic> && item['name'] is String)
        .map((item) => item['name'] as String)
        .toList();
    Color getRandomColor() {
      Random random = Random();
      const int maxColorValue = 200;
      return Color.fromARGB(
        255,
        random.nextInt(maxColorValue),
        random.nextInt(maxColorValue),
        random.nextInt(maxColorValue),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: Column(
          children: [
            Appbar(
              title: widget.item['title'],
              color: widget.color,
              homeBtn: true,
            ),
            Container(
              decoration: BoxDecoration(color: widget.color),
              width: double.infinity,
              child: OverlapCircleAvatars(
                  users: names, getRandomColor: getRandomColor),
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshList,
        child: Stack(
          children: [
            ListView.builder(
              itemCount: listItems.length,
              itemBuilder: (context, index) {
                var item = listItems[index];
                String creator = listItems[index]['creator'] ?? "unknown";
                Duration animationDelay = Duration(milliseconds: 100 * index);
                return Animate(
                  effects: const [FadeEffect()],
                  delay: animationDelay,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: listItems[index]['checked'],
                                onChanged: (bool? value) {
                                  _onCheckboxChanged(value, index);
                                },
                                shape: const CircleBorder(),
                                activeColor: widget.color,
                                checkColor: widget.color,
                              ),
                              title: GestureDetector(
                                onTap: () {
                                  bool? currentValue =
                                      listItems[index]['checked'];
                                  _onCheckboxChanged(!currentValue!, index);
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  decoration: const BoxDecoration(),
                                  child: Text(
                                    item['item'],
                                    style: TextStyle(
                                        color: listItems[index]['checked']
                                            ? widget.color
                                            : null,
                                        fontWeight: listItems[index]['checked']
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: _showTooltip,
                                    child: Tooltip(
                                      message: creator,
                                      key: _toolTipKey,
                                      child: CircleAvatar(
                                        radius: 15,
                                        child: Text(
                                          creator.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuButton<String>(
                                        tooltip: "הראה תפריט",
                                        position: PopupMenuPosition.under,
                                        onSelected: (String result) async {
                                          if (result == 'delete') {
                                            deleteItem(index);
                                          }
                                          if (result == 'edit') {
                                            _editItem.showAlertDialog(
                                                context,
                                                widget.color,
                                                widget.item['docId'],
                                                refreshList,
                                                listItems[index]['item'],
                                                index,
                                                widget.item['sharedWith'],
                                                widget.item['listId']);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Icon(Icons.delete),
                                                Text("מחק רשימה"),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Icon(Icons.edit),
                                                Text("ערוך רשימה"),
                                              ],
                                            ),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (listItems.length == checkedCount)
              Animate(
                effects: const [
                  SlideEffect(
                    begin: Offset(0, 1),
                    end: Offset(0, 0),
                    duration: Duration(milliseconds: 300),
                  ),
                ],
                child: Positioned(
                  bottom: 20,
                  left: 10,
                  child: Material(
                    elevation: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: finishList,
                        child: const Text(
                          "סיים רשימה",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 20,
                left: 10,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "$checkedCount :משימות שבוצעו",
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        tooltip: "צור משימה",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => BottomModalCreateItem(
              color: widget.color,
              docId: widget.item['docId'],
              listId: widget.item['listId'],
              sharedWith: widget.item['sharedWith'],
              onItemCreated: refreshList,
            ),
          );
        },
        backgroundColor: widget.color,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
