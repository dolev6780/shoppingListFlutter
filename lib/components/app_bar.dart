import 'package:flutter/material.dart';

class Appbar extends StatelessWidget {
  final String title;
  final bool backBtn;
  final Color color;
  const Appbar(
      {super.key,
      required this.title,
      required this.backBtn,
      required this.color});

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(),
      ),
      centerTitle: true,
      automaticallyImplyLeading: backBtn,
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: color,
      iconTheme: IconThemeData(color: textColor),
    );
  }
}
