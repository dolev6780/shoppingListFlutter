import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/services/connection_service.dart';

class PopupConnections {
  final ConnectionService connectionService = ConnectionService();

  void showAlertDialog(
      BuildContext context, List<String> selectedUIDs, Color themeColor) async {
    List<Map<String, dynamic>> connections =
        await connectionService.fetchConnections();
    List<String> toShareSelectedUIDs = List.from(selectedUIDs);
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
                                String connectionId = connection['id']
                                    .toString(); //get connection id
                                String connectionName = connection['name']
                                    .toString(); // get connection name
                                bool isSelected =
                                    toShareSelectedUIDs.contains(connectionId);
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: themeColor,
                                      child: Text(
                                        connectionName[0]
                                            .toString()
                                            .toUpperCase(),
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
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          toShareSelectedUIDs
                                              .remove(connectionId);
                                        } else {
                                          toShareSelectedUIDs.add(connectionId);
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
                    selectedUIDs.clear();
                    selectedUIDs.addAll(toShareSelectedUIDs);
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
