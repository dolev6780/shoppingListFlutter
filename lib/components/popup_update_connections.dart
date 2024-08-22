// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/services/data_service.dart';

class PopupUpdateConnections {
  final DataService dataService = DataService();

  Future<void> showAlertDialog(BuildContext context,
      List<dynamic> currentSharedWith, Color themeColor) async {
    List<Map<String, dynamic>> connections =
        await dataService.fetchConnections();

    // Prepare a list of IDs for quick lookup
    Set<String> currentSharedIds = currentSharedWith
        .whereType<Map<String, dynamic>>()
        .map((item) => item['id'].toString())
        .toSet();

    // Prepare list of selected users with proper conversion
    List<Map<String, String>> toShareSelectedUIDs = currentSharedWith
        .whereType<Map<String, dynamic>>()
        .map((item) => {
              'id': item['id'].toString(),
              'name': item['name'].toString(),
            })
        .toList();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              elevation: 8,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: Center(
                child: Text(
                  "שתף רשימה",
                  style: TextStyle(
                      fontSize: 20,
                      color: themeColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  connections.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const Text(
                                  "הוסף חברים לאנשי הקשר שלך כדי לשתף אותם"),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            const MyConnectionsScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "אנשי קשר",
                                    style: TextStyle(color: themeColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 200.0,
                          width: 300,
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: connections.length,
                              itemBuilder: (context, index) {
                                var connection = connections[index];
                                String connectionId =
                                    connection['id'].toString();
                                String connectionName =
                                    connection['name'].toString();
                                bool isSelected =
                                    currentSharedIds.contains(connectionId);

                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: themeColor,
                                      child: Text(
                                        connectionName[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                    title: Text(
                                      connectionName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    trailing: Checkbox(
                                      activeColor: themeColor,
                                      shape: const CircleBorder(),
                                      checkColor: themeColor,
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            if (!currentSharedIds
                                                .contains(connectionId)) {
                                              currentSharedIds
                                                  .add(connectionId);
                                              toShareSelectedUIDs.add({
                                                'id': connectionId,
                                                'name': connectionName
                                              });
                                            }
                                          } else {
                                            currentSharedIds
                                                .remove(connectionId);
                                            toShareSelectedUIDs.removeWhere(
                                                (element) =>
                                                    element['id'] ==
                                                    connectionId);
                                          }
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          currentSharedIds.remove(connectionId);
                                          toShareSelectedUIDs.removeWhere(
                                              (element) =>
                                                  element['id'] ==
                                                  connectionId);
                                        } else {
                                          currentSharedIds.add(connectionId);
                                          toShareSelectedUIDs.add({
                                            'id': connectionId,
                                            'name': connectionName
                                          });
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "סגור",
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    currentSharedWith.clear();
                    currentSharedWith.addAll(toShareSelectedUIDs);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "שתף",
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
