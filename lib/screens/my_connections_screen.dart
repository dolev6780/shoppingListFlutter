import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/bottom_modal_add_connection.dart';
import 'package:shoppinglist/services/connection_service.dart';
import 'package:shoppinglist/services/theme_provider.dart';

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen> {
  final ConnectionService connectionService = ConnectionService();

  Future<void> _refreshConnections() async {
    // Call the method to fetch connections
    await connectionService.fetchConnections();
    // Refresh state after fetching connections
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;
    Color textColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(color: themeColor),
        ),
        title: Text(
          'אנשי הקשר שלי',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConnections,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: connectionService.fetchConnections(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching connections'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No connections found'));
            } else {
              List<Map<String, dynamic>> connections = snapshot.data!;
              return ListView.builder(
                itemCount: connections.length,
                itemBuilder: (context, index) {
                  var connection = connections[index];
                  return Column(
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: themeColor,
                              child: Text(
                                connection['name'][0].toString().toUpperCase(),
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            title: Text(
                              connection['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: themeColor),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('מחיקת איש קשר'),
                                    content: const Text(
                                        'האם אתה בטוח שתרצה למחוק את האיש קשר?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                          'בטל',
                                          style: TextStyle(color: themeColor),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text(
                                          'אשר',
                                          style: TextStyle(color: themeColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmDelete == true) {
                                  await connectionService
                                      .deleteConnection(connection['id']);
                                  // Refresh connections after deletion
                                  _refreshConnections();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        endIndent: 20,
                        indent: 20,
                        color: themeColor,
                      )
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const BottomModalAddConnection(),
          );
        },
        label: Text(
          "הוסף איש קשר",
          style: TextStyle(color: textColor),
        ),
        backgroundColor: themeColor,
      ),
    );
  }
}
