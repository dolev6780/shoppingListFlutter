import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'HomeScreen.dart';

class TheListScreen extends StatefulWidget {
  final String title;
  final List list;
  final String docId;
  final String uid;
  const TheListScreen(
      {super.key,
      required this.title,
      required this.list,
      required this.docId,
      required this.uid});

  @override
  State<TheListScreen> createState() => _TheListScreenState();
}

class _TheListScreenState extends State<TheListScreen> {
  bool finishedList = false;
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
            ));
      }
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

  bool value = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 90),
        child: Container(
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
                      : Text(''),
                  const SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                      backgroundColor: widget.list[index]['checked'] == true
                          ? Colors.green
                          : Colors.blue,
                      radius: 15,
                      child: Text(widget.list[index]['qty'].toString())),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.list[index]['item'].toString(),
                    style: TextStyle(
                        color: widget.list[index]['checked'] == true
                            ? Colors.green
                            : Colors.white,
                        fontWeight: widget.list[index]['checked'] == true
                            ? FontWeight.bold
                            : FontWeight.normal),
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
                  icon: Icon(Icons.delete)),
            );
          },
        )),
      ),
      floatingActionButton: finishedList == true
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: Text(
                'סיים רשימה',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}