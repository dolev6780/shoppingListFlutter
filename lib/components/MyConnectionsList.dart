import 'package:flutter/material.dart';

class MyConnectionsList extends StatelessWidget {
  final List myConnections;
  const MyConnectionsList({super.key, required this.myConnections});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: myConnections.isNotEmpty
          ? ListView.builder(
              itemCount: myConnections.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(left: 8, right: 8),
                  title: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      CircleAvatar(
                          radius: 15,
                          child: Text(myConnections[index]['user']
                              .toString()
                              .toUpperCase()
                              .substring(0, 1))),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(myConnections[index]['user']),
                    ],
                  ),
                );
              },
            )
          : SizedBox(),
    );
  }
}
