import 'package:flutter/material.dart';

class OverlapCircleAvatars extends StatelessWidget {
  final List<String> users;
  final Color Function() getRandomColor;

  const OverlapCircleAvatars({
    Key? key,
    required this.users,
    required this.getRandomColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 40,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<String>(
              tooltip: "הראה תפריט",
              icon: SizedBox(
                width: 30,
                height: 20,
                child: Stack(
                  children: [
                    for (int i = 0;
                        i < (users.length > 2 ? 2 : users.length);
                        i++)
                      Positioned(
                        right: 8.0 * i,
                        child: CircleAvatar(
                          backgroundColor: getRandomColor(),
                          radius: 10,
                          child: Text(
                            users[i].substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              padding: EdgeInsets.zero,
              onSelected: (String value) {
                // Handle selection
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    enabled: false,
                    padding: EdgeInsets.zero,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: users.map((String user) {
                            return PopupMenuItem<String>(
                              value: user,
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: getRandomColor(),
                                      child: Text(
                                        user.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(user),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              offset: const Offset(0, 50),
            ),
          ),
        ],
      ),
    );
  }
}
