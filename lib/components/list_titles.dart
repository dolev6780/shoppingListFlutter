import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/screens/create_list_screen.dart';
import 'package:shoppinglist/screens/the_list_screen.dart';

class ListTitles extends StatefulWidget {
  const ListTitles({Key? key}) : super(key: key);

  @override
  State<ListTitles> createState() => ListTitlesState();
}

class ListTitlesState extends State<ListTitles> {
  User? _user;
  List<Map<String, dynamic>> listTitles = [];
  List<bool> isOpen = [];
  late QuerySnapshot snapshot;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    var subCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc("${_user?.uid}")
        .collection('lists');
    if (!(_user?.uid == null)) {
      subCollectionRef.snapshots().listen((querySnapshot) {
        snapshot = querySnapshot;
        List<Map<String, dynamic>> newListTitles = [];

        querySnapshot.docs
            .where((doc) => doc.data()['finished'] == false)
            .forEach((doc) {
          newListTitles.add({
            'creator': doc.data()['creator'],
            'title': doc.data()['title'],
            'date': doc.data()['date'],
            'list': doc.data()['list'],
            'docId': doc.id,
            'color': doc.data()['color'],
            'textColor': doc.data()['textColor'],
          });
        });
        setState(() {
          listTitles = newListTitles;
          isOpen = List<bool>.generate(listTitles.length, (index) => false);
        });
      });
    } else {
      listTitles = [];
    }
  }

  void deleteList(docId) {
    var subCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc("${_user?.uid}")
        .collection('lists')
        .doc(docId);
    subCollectionRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: listTitles.isNotEmpty
          ? ListView.builder(
              itemCount: listTitles.length,
              addAutomaticKeepAlives: true,
              itemBuilder: (BuildContext context, int index) {
                var docId = listTitles[index]['docId'];
                Color backgroundColor =
                    parseColor(listTitles[index]['color']) ??
                        const Color.fromARGB(255, 20, 67, 117);
                Color textColor =
                    parseColor(listTitles[index]['textColor']) ?? Colors.white;
                return Column(
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
                                uid: "${_user?.uid}",
                                color: backgroundColor,
                                textColor: textColor),
                          ),
                        );
                      },
                      child: Material(
                        elevation: 8,
                        shadowColor: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 34, 34, 34),
                              // border: Border.all(
                              //   color: Colors.black,
                              //   width: 2,
                              // ),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 30,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6))),
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                  listTitles[index]["title"],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      deleteList(docId);
                                    },
                                    icon: const Icon(
                                      Icons.more_vert,
                                    ),
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          listTitles[index]['title'],
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${listTitles[index]['creator']?.toString().substring(0, listTitles[index]['creator'].toString().indexOf('@'))} :יוצר",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                        "${listTitles[index]['date']?.toString()}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const CreateListScreen(),
                  ),
                );
              },
              child: const SizedBox(
                child: Center(
                  child: Text(
                    "לחץ על רשימה חדשה או הקש על המסך בשביל ליצור רשימת קניות ",
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w200,
                      color: Color.fromARGB(255, 118, 108, 108),
                    ),
                  ),
                ),
              ),
            ),
    );
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
}
