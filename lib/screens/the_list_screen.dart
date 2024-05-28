// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/app_bar.dart';
import 'home_screen.dart';

class TheListScreen extends StatefulWidget {
  final String creator;
  final String title;
  final List list;
  final String docId;
  final String uid;

  const TheListScreen({
    Key? key,
    required this.creator,
    required this.title,
    required this.list,
    required this.docId,
    required this.uid,
  }) : super(key: key);

  @override
  State<TheListScreen> createState() => _TheListScreenState();
}

class _TheListScreenState extends State<TheListScreen> {
  bool finishedList = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _checkFinishedList();
    });
  }

  Future<void> updateSubcollectionField() async {
    try {
      // Get a reference to the document that contains the subcollection
      var docRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);

      // Get a reference to the subcollection
      var subcollectionRef = docRef.collection('shoplists');

      // Update the field in the subcollection document
      await subcollectionRef.doc(widget.docId).update({'list': widget.list});
      if (widget.list.isEmpty) {
        await subcollectionRef.doc(widget.docId).delete();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error updating subcollection field: $e');
    }
  }

  Future<void> finishList() async {
    try {
      var docRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);
      var subcollectionRef = docRef.collection('shoplists');

      await subcollectionRef.doc(widget.docId).update({'finished': true});

      // Navigate to the HomeScreen after updating the collection
      // ignore: use_build_context_synchronously
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      print('Error updating subcollection field: $e');
    }
  }

  void _checkFinishedList() {
    for (var i = 0; i < widget.list.length; i++) {
      if (widget.list[i]['checked'] == false) {
        setState(() {
          finishedList = false;
        });
        return;
      }
    }
    setState(() {
      finishedList = true;
    });
  }

  void _onItemChecked(int index) {
    setState(() {
      widget.list[index]['checked'] = !widget.list[index]['checked'];
    });
    _checkFinishedList();
    updateSubcollectionField();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Appbar(
            title: widget.title,
            backBtn: true,
          )),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 90),
            child: ListView.builder(
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      _onItemChecked(index);
                    });
                  },
                  tileColor: index % 2 != 0
                      ? Colors.blueGrey.shade100
                      : Colors.blue.shade200,
                  title: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      widget.list[index]['checked'] == true
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : const Text(''),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: widget.list[index]['checked'] == true
                            ? Colors.green
                            : Colors.blue,
                        radius: 15,
                        child: Text(widget.list[index]['qty'].toString()),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.list[index]['item'].toString(),
                        style: TextStyle(
                          color: widget.list[index]['checked'] == true
                              ? Colors.green
                              : Colors.white,
                          fontWeight: widget.list[index]['checked'] == true
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  leading: IconButton(
                    onPressed: () {
                      setState(() {
                        widget.list.removeAt(index);
                        updateSubcollectionField();
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "editButton",
              onPressed: () {
                // Perform some action for the "Edit" button if needed.
                // For example, you could open a dialog to edit the list.
              },
              child: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
      floatingActionButton: finishedList == true
          ? FloatingActionButton.extended(
              heroTag: "addConnectionButton",
              onPressed: () async {
                finishList();
              },
              label: const Text(
                'סיים רשימה',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
