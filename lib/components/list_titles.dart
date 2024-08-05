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
    List<Map<String, dynamic>> listTitles = [];

    if (user != null) {
      try {
        var subCollectionRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('lists');

        var querySnapshot = await subCollectionRef.get();

        listTitles = querySnapshot.docs
            .where((doc) => doc.data()['finished'] == false)
            .map((doc) {
          return {
            'creator': doc.data()['creator'],
            'title': doc.data()['title'],
            'date': doc.data()['date'],
            'list': doc.data()['list'],
            'docId': doc.id,
            'color': doc.data()['color'],
            'textColor': doc.data()['textColor'],
          };
        }).toList();
      } catch (e) {
        print('Error fetching list titles: $e');
      }
    }

    return listTitles;
  }

  Future<void> deleteList(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('Deleting list with docId: $docId');

      var subCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc(docId);

      try {
        await subCollectionRef.delete();
        print('List deleted successfully');
        await widget.refreshLists();
      } catch (e) {
        print('Error deleting list: $e');
      } finally {
        setState(() {});
      }
    }
  }

  Color? parseColor(String? colorString) {
    if (colorString != null && colorString.isNotEmpty) {
      try {
        if (colorString.startsWith('#')) {
          return Color(
              int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
        } else {
          return Color(int.parse(colorString));
        }
      } catch (e) {
        print('Error parsing color: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchListTitles(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "לחץ על רשימה חדשה בשביל ליצור רשימת קניות ",
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
          final listTitles = snapshot.data!;
          return ListView.builder(
            itemCount: listTitles.length,
            itemBuilder: (BuildContext context, int index) {
              var docId = listTitles[index]['docId'];
              Color backgroundColor = parseColor(listTitles[index]['color']) ??
                  const Color.fromARGB(255, 20, 67, 117);
              Color textColor =
                  parseColor(listTitles[index]['textColor']) ?? Colors.white;
              return Animate(
                effects: const [FlipEffect()],
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => TheListScreen(
                              creator: listTitles[index]['creator'],
                              title: listTitles[index]['title'],
                              list: listTitles[index]['list'],
                              docId: docId,
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              color: backgroundColor,
                              textColor: textColor,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 10,
                                  color: Color.fromARGB(140, 156, 156, 156),
                                  offset: Offset(0, 2))
                            ],
                            color: Colors.white),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: ListTile(
                                  title: Text(
                                    listTitles[index]['title'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
                                                  listId: docId,
                                                  initialTitle:
                                                      listTitles[index]
                                                          ['title'],
                                                  initialColor: backgroundColor,
                                                  initialTextColor: textColor,
                                                ).showAlertDialog(context);
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Color.fromARGB(
                                                            255, 20, 67, 117)),
                                                    Text(
                                                      "מחק רשימה",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Icon(Icons.edit,
                                                        color: Color.fromARGB(
                                                            255, 20, 67, 117)),
                                                    Text(
                                                      "ערוך רשימה",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                            icon: const Icon(Icons.more_vert,
                                                color: Color.fromARGB(
                                                    255, 20, 67, 117)),
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
                                    listTitles[index]['date'],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 77, 77, 77)),
                                  ),
                                  iconColor:
                                      const Color.fromARGB(255, 20, 67, 117),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}

///Row(
//                           children: [
//                             PopupMenuButton<String>(
//                               color: const Color.fromARGB(255, 34, 34, 34),
//                               position: PopupMenuPosition.under,
//                               onSelected: (String result) async {
//                                 if (result == 'delete') {
//                                   await deleteList(docId);
//                                 }
//                                 if (result == 'edit') {
//                                   EditList(
//                                     listId: docId,
//                                     initialTitle: listTitles[index]['title'],
//                                     initialColor: backgroundColor,
//                                     initialTextColor: textColor,
//                                   ).showAlertDialog(context);
//                                 }
//                               },
//                               itemBuilder: (BuildContext context) => [
//                                 const PopupMenuItem<String>(
//                                   value: 'delete',
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Icon(Icons.delete, color: Colors.white),
//                                       Text(
//                                         "מחק רשימה",
//                                         style: TextStyle(color: Colors.white),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 const PopupMenuItem<String>(
//                                   value: 'edit',
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Icon(Icons.edit, color: Colors.white),
//                                       Text(
//                                         "ערוך רשימה",
//                                         style: TextStyle(color: Colors.white),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                               icon: const Icon(Icons.more_vert,
//                                   color: Colors.white),
//                             ),
//                           ],
//                         ),
