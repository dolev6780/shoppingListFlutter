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
      decoration: const BoxDecoration(color: Color.fromARGB(255, 20, 67, 117)),
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
