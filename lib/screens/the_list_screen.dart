import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoppinglist/components/bottom_modal_create_item.dart';
import 'package:shoppinglist/components/edit_item.dart';
import '../components/app_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TheListScreen extends StatefulWidget {
  final String creator;
  final String title;
  final List list;
  final String docId;
  final String uid;
  final Color color;
  final Color textColor;

  const TheListScreen({
    Key? key,
    required this.creator,
    required this.title,
    required this.list,
    required this.docId,
    required this.uid,
    required this.color,
    required this.textColor,
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
      var docRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);
      var subcollectionRef = docRef.collection('lists');
      await subcollectionRef.doc(widget.docId).update({'list': listItems});
      print("Updated Firestore with list items");
    } catch (e) {
      print('Error updating subcollection field: $e');
    }
  }

  Future<void> refreshList() async {
    try {
      var docRef =
          FirebaseFirestore.instance.collection('users').doc(widget.uid);
      var subcollectionRef = docRef.collection('lists');
      var documentSnapshot = await subcollectionRef.doc(widget.docId).get();
      setState(() {
        listItems = documentSnapshot.data()?['list'] ?? [];
        checkedCount =
            listItems.where((item) => item['checked'] == true).length;
        print("Refreshed list items: $listItems");
      });
    } catch (e) {
      print('Error refreshing list: $e');
    }
  }

  void _onCheckboxChanged(bool? value, int index) {
    setState(() {
      listItems[index]['checked'] = value;
      checkedCount = listItems.where((item) => item['checked'] == true).length;
    });
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
          color: widget.color,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ListView.builder(
              itemCount: listItems.length,
              itemBuilder: (context, index) {
                var item = listItems[index];
                Duration animationDelay = Duration(milliseconds: 100 * index);
                return Animate(
                  effects: const [FadeEffect()],
                  delay: animationDelay,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      blurRadius: 4,
                                      color: Color.fromARGB(255, 151, 151, 151),
                                      offset: Offset(0, 2))
                                ],
                                color: Colors.white),
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
                                            : Colors.black,
                                        fontWeight: listItems[index]['checked']
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.black),
                                    onPressed: () => _editItem.showAlertDialog(
                                      context,
                                      widget.color,
                                      widget.docId,
                                      refreshList,
                                      listItems[index]['item'],
                                      index,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.black),
                                    onPressed: () async {
                                      setState(() {
                                        listItems.removeAt(index);
                                        checkedCount = listItems
                                            .where((item) =>
                                                item['checked'] == true)
                                            .length;
                                      });
                                      await updateSubcollectionField();
                                    },
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
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color.fromARGB(255, 202, 202, 202),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () => {},
                    child: const Text(
                      "סיים רשימה",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              bottom: 20,
              left: 10,
              child: Container(
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
              docId: widget.docId,
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
