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
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(),
      ),
      centerTitle: true,
      automaticallyImplyLeading: backBtn,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
