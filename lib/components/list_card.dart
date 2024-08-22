// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/edit_list.dart';
import 'package:shoppinglist/components/overlap_circle_avatar.dart';
import 'package:shoppinglist/screens/the_list_screen.dart';
import 'package:shoppinglist/services/data_service.dart';
import 'dart:math';

import 'package:shoppinglist/services/theme_provider.dart';

class ListCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function refreshLists;
  final DataService dataService;

  const ListCard({
    super.key,
    required this.item,
    required this.refreshLists,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    var docId = item['docId'];
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;
    List<dynamic> sharedWith = item['sharedWith'];
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

    String creator = item['creator'];
    int listItemsAmount = item['list'].length;
    return Animate(
      effects: const [FlipEffect()],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "מאת: $creator",
                      ),
                      Text(
                        item['date'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  item['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      tooltip: "הראה תפריט",
                      position: PopupMenuPosition.under,
                      onSelected: (String result) async {
                        if (result == 'delete') {
                          await dataService.deleteList(docId);
                          refreshLists();
                        }
                        if (result == 'edit') {
                          EditList(
                            listId: item['listId'],
                            initialTitle: item['title'],
                            initialColor: themeColor,
                            sharedWith: item['sharedWith'],
                          ).showAlertDialog(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.delete, color: themeColor),
                              const Text("מחק רשימה"),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.edit, color: themeColor),
                              const Text("ערוך רשימה"),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(Icons.more_vert, color: themeColor),
                    ),
                    const Icon(Icons.list, size: 32),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                iconColor: themeColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => TheListScreen(
                        item: item,
                        color: themeColor,
                        uid: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        OverlapCircleAvatars(
                            users: names, getRandomColor: getRandomColor),
                      ],
                    ),
                    Text("כמות פריטים: $listItemsAmount")
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
