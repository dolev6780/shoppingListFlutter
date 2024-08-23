import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/services/theme_provider.dart';
import '../components/app_bar.dart';

class FinishedListsScreen extends StatefulWidget {
  const FinishedListsScreen({super.key});

  @override
  State<FinishedListsScreen> createState() => _FinishedListsScreenState();
}

class _FinishedListsScreenState extends State<FinishedListsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchFinishedLists() async {
    try {
      final User? user = Provider.of<User?>(context, listen: false);

      if (user == null) {
        throw Exception("User not authenticated");
      }

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .where('finished', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      //print('Error fetching finished lists: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(
          title: "היסטוריית רשימות",
          color: themeColor,
          homeBtn: true,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFinishedLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "לא נמצאו רשימות היסטוריות",
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                  color: Color.fromARGB(255, 255, 0, 0),
                ),
              ),
            );
          } else {
            final finishedLists = snapshot.data!;
            return ListView.builder(
              itemCount: finishedLists.length,
              itemBuilder: (context, index) {
                final list = finishedLists[index];
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Card(
                    child: ExpansionTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            tooltip: "הראה תפריט",
                            position: PopupMenuPosition.under,
                            onSelected: (String result) async {
                              if (result == 'delete') {
                                // await dataService.deleteList(docId);
                                // refreshLists();
                              }
                              if (result == 'duplicate') {}
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.delete_forever,
                                          color: themeColor),
                                      const Text("מחק רשימה לצמיתות"),
                                    ],
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'duplicate',
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.file_copy, color: themeColor),
                                      const Text("שכפל רשימה"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            icon: Icon(Icons.more_vert, color: themeColor),
                          ),
                          const Icon(Icons.list, size: 32),
                        ],
                      ),
                      title: ListTile(
                        title: Text(list['title'] ?? 'No Title'),
                        subtitle: Text('יוצר רשימה: ${list['creator'] ?? ''}'),
                      ),
                      subtitle: Text('נוצר ב: ${list['date'] ?? ''}'),
                      children: [
                        const Divider(),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "רשימת הפריטים",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...?list['list']?.map<Widget>((item) {
                          return ListTile(
                            title: Text(item['item'] ?? 'No Name'),
                            subtitle: Text(
                              'יוצר: ${item['creator'] ?? ''}',
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
