import 'package:flutter/material.dart';
import 'package:shoppinglist/screens/home_screen.dart';

class Appbar extends StatelessWidget {
  final String title;
  final Color color;
  final bool homeBtn;
  const Appbar(
      {super.key,
      required this.title,
      required this.color,
      required this.homeBtn});

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: color,
      iconTheme: IconThemeData(color: textColor),
      leading: homeBtn
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                )
              },
            )
          : null,
    );
  }
}
