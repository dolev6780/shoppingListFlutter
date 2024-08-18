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
      height: 20,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          icon: const SizedBox(),
          menuMaxHeight: 250,
          isExpanded: true,
          items: users.map((String user) {
            return DropdownMenuItem<String>(
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
                            fontSize: 12, fontWeight: FontWeight.bold),
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
          onChanged: (String? newValue) {
            // Handle action if needed when user selects a name
          },
          hint: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Stack(
              children: [
                for (int i = 0; i < (users.length > 3 ? 3 : users.length); i++)
                  Positioned(
                    right: 10.0 * i,
                    child: CircleAvatar(
                      backgroundColor: getRandomColor(),
                      radius: 10,
                      child: Text(
                        users[i].substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (users.length > 3)
                  Positioned(
                    right: 30.0,
                    child: CircleAvatar(
                      backgroundColor: getRandomColor(),
                      radius: 10,
                      child: Text(
                        '+${users.length - 3}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
