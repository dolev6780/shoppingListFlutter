import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/screens/the_list_screen.dart';
import 'package:shoppinglist/components/edit_list.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ListTitles extends StatefulWidget {
  final Future<void> Function() refreshLists;

  const ListTitles({Key? key, required this.refreshLists}) : super(key: key);

  @override
  _ListTitlesState createState() => _ListTitlesState();
}

class _ListTitlesState extends State<ListTitles> {
  Future<List<Map<String, dynamic>>> fetchListTitles() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    try {
      var subCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lists');

      var querySnapshot = await subCollectionRef.get();

      return querySnapshot.docs
          .where((doc) => doc.data()['finished'] == false)
          .map((doc) => {
                'type': 'list',
                'color': doc.data()['color'],
                'creator': doc.data()['creator'],
                'date': doc.data()['date'],
                'finished': doc.data()['finished'],
                'list': doc.data()['list'],
                'listId': doc.data()['listId'],
                'sharedWith': doc.data()['sharedWith'],
                'title': doc.data()['title'],
                'docId': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error fetching list titles: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPendingListTitles() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      var subCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pendingLists');

      var querySnapshot = await subCollectionRef.get();

      return querySnapshot.docs
          .map((doc) => {
                'type': 'pending',
                'color': doc.data()['color'] ?? '#FFFFFF',
                'creator': doc.data()['creator'] ?? 'Unknown',
                'date': doc.data()['date'] ?? 'No date',
                'finished': doc.data()['finished'] ?? false,
                'list': doc.data()['list'] ?? [],
                'listId': doc.data()['listId'] ?? "",
                'sharedWith': doc.data()['sharedWith'] ?? "",
                'title': doc.data()['title'] ?? 'Untitled',
                'docId': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error fetching pending list titles: $e');
      return [];
    }
  }

  Future<void> deleteList(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc(docId)
          .delete();

      await widget.refreshLists();
    } catch (e) {
      print('Error deleting list: $e');
    }
  }

  Future<void> deletePendingList(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pendingLists')
          .doc(docId)
          .delete();

      await widget.refreshLists();
    } catch (e) {
      print('Error deleting pending list: $e');
    }
  }

  Future<void> approvePendingList(
      Map<String, dynamic> item, String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final docData = {
        "color": item['color'],
        "creator": item['creator'],
        "date": item['date'],
        "finished": item['finished'],
        "list": item['list'],
        "listId": item['listId'],
        "sharedWith": item['sharedWith'],
        "title": item['title'],
      };
      final DocumentReference newDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc();

      await newDocRef.set(docData);
      await deletePendingList(docId);

      // Refresh lists to ensure UI updates
      await widget.refreshLists();

      // Rebuild the widget tree to reflect the new data
      setState(() {});
    } catch (e) {
      print('Error approving pending list: $e');
    }
  }

  Color? parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      return colorString.startsWith('#')
          ? Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000)
          : Color(int.parse(colorString));
    } catch (e) {
      print('Error parsing color: $e');
      return null;
    }
  }

  Future<void> handlePendingList(
      bool approved, String docId, Map<String, dynamic> item) async {
    if (approved) {
      await approvePendingList(item, docId);
    } else {
      await deletePendingList(docId);
    }
  }

  Widget buildPendingListCard(Map<String, dynamic> item) {
    var docId = item['docId'];
    var creator = item['creator'];

    return Animate(
      effects: [ShakeEffect()],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item['title']),
                  const SizedBox(width: 20),
                  Text(
                    item['date'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              subtitle: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.up,
                  children: [
                    const Text(
                      'רוצה לשתף אותך ברשימה חדשה',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '$creator',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => {handlePendingList(true, docId, item)},
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                      shadows: [
                        BoxShadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Color.fromARGB(255, 184, 184, 184))
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () => {handlePendingList(false, docId, item)},
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 30,
                        shadows: [
                          BoxShadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Color.fromARGB(255, 184, 184, 184))
                        ],
                      )),
                ],
              ),
              leading: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.list)],
              )),
        ),
      ),
    );
  }

  Widget buildRegularListCard(Map<String, dynamic> item) {
    var docId = item['docId'];
    Color backgroundColor =
        parseColor(item['color']) ?? const Color.fromARGB(255, 20, 67, 117);
    Color textColor = parseColor(item['textColor']) ?? Colors.white;

    return Animate(
      effects: const [FlipEffect()],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              item['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    PopupMenuButton<String>(
                      color: Colors.white,
                      position: PopupMenuPosition.under,
                      onSelected: (String result) async {
                        if (result == 'delete') {
                          await deleteList(docId);
                        }
                        if (result == 'edit') {
                          EditList(
                            listId: item['listId'],
                            initialTitle: item['title'],
                            initialColor: backgroundColor,
                            sharedWith: item['sharedWith'],
                          ).showAlertDialog(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.delete,
                                  color: Color.fromARGB(255, 20, 67, 117)),
                              Text(
                                "מחק רשימה",
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.edit,
                                  color: Color.fromARGB(255, 20, 67, 117)),
                              Text(
                                "ערוך רשימה",
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert,
                          color: Color.fromARGB(255, 20, 67, 117)),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.list,
                  size: 32,
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            subtitle: Text(
              item['date'],
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 77, 77, 77)),
            ),
            iconColor: const Color.fromARGB(255, 20, 67, 117),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => TheListScreen(
                    creator: item['creator'],
                    title: item['title'],
                    list: item['list'],
                    docId: docId,
                    uid: FirebaseAuth.instance.currentUser!.uid,
                    color: backgroundColor,
                    textColor: textColor,
                    listId: item['listId'],
                    sharedWith: item['sharedWith'],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        fetchPendingListTitles(),
        fetchListTitles(),
      ]),
      builder: (BuildContext context,
          AsyncSnapshot<List<List<Map<String, dynamic>>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "לחץ על רשימה חדשה בשביל ליצור רשימת קניות",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w200,
                color: Color.fromARGB(255, 118, 108, 108),
              ),
            ),
          );
        } else {
          final pendingListTitles = snapshot.data![0];
          final listTitles = snapshot.data![1];

          final combinedList = <Map<String, dynamic>>[];

          if (pendingListTitles.isNotEmpty) {
            combinedList.addAll(pendingListTitles);
          }
          combinedList.addAll(listTitles);
          return ListView.builder(
              itemCount: combinedList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = combinedList[index];
                if (item['type'] == 'pending') {
                  return buildPendingListCard(item);
                } else {
                  return buildRegularListCard(item);
                }
              });
        }
      },
    );
  }
}
