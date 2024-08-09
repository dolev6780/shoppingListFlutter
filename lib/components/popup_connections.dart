import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/services/connection_service.dart';

class PopupConnections {
  final ConnectionService connectionService = ConnectionService();

  void showAlertDialog(BuildContext context, List<String> selectedUIDs) async {
    List<String> connections = await connectionService.fetchConnections();
    List<String> toShareSelectedUIDs = List.from(selectedUIDs);

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              elevation: 8,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: const Center(
                child: Text(
                  "שתף את הרשימה עם אחרים",
                  style: TextStyle(fontSize: 14),
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
                                  child: const Text("אנשי קשר"),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 200.0,
                          width: 300,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: connections.length,
                            itemBuilder: (context, index) {
                              var connection = connections[index];
                              String connectionId = connection
                                  .toString(); // Ensure it's treated as String
                              bool isSelected =
                                  toShareSelectedUIDs.contains(connectionId);
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color.fromARGB(
                                          255, 20, 67, 117),
                                      child: Text(
                                        connection['displayName'][0]
                                            .toString()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      connection['displayName'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            if (!toShareSelectedUIDs
                                                .contains(connectionId)) {
                                              toShareSelectedUIDs
                                                  .add(connectionId);
                                            }
                                          } else {
                                            toShareSelectedUIDs
                                                .remove(connectionId);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("סגור"),
                ),
                TextButton(
                  onPressed: () {
                    selectedUIDs.clear();
                    selectedUIDs.addAll(toShareSelectedUIDs);
                    print(selectedUIDs);
                    Navigator.pop(context);
                  },
                  child: const Text("שתף"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
