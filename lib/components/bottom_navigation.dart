import 'package:flutter/material.dart';

class GradientBottomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GradientBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 140, 255),
            Color.fromARGB(255, 0, 119, 255)
          ], // Set your gradient colors here
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor:
            Colors.transparent, // Set the background color to transparent
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
      ),
    );
  }
}
