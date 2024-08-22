import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/overlap_circle_avatar.dart';
import 'package:shoppinglist/services/data_service.dart';
import 'dart:math';

import 'package:shoppinglist/services/theme_provider.dart';

class PendingListCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(bool, String, Map<String, dynamic>) handlePendingList;
  final DataService dataService;
  const PendingListCard({
    super.key,
    required this.item,
    required this.handlePendingList,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    var docId = item['docId'];
    String creator = item['creator'];

    List<dynamic> sharedWith = item['sharedWith'];
    List<String> names = sharedWith
        .where((item) => item is Map<String, dynamic> && item['name'] is String)
        .map((item) => item['name'] as String)
        .toList();
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;

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

    return Animate(
      effects: const [ShakeEffect()],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        "מאת: $creator",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      item['date'],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              ListTile(
                title: Text(
                  "רשימה חדשה ממתינה",
                  style: TextStyle(fontSize: 12, color: themeColor),
                ),
                subtitle: Text(
                  item['title'],
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => handlePendingList(true, docId, item),
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () => handlePendingList(false, docId, item),
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OverlapCircleAvatars(
                        users: names, getRandomColor: getRandomColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
