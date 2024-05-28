import 'package:flutter/material.dart';

class Appbar extends StatelessWidget {
  final String title;
  final bool backBtn;
  const Appbar({super.key, required this.title, required this.backBtn});

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 140, 255),
              Color.fromARGB(255, 0, 89, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: backBtn,
      title: Text(title),
    );
  }
}
