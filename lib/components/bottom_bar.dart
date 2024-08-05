import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:shoppinglist/components/bottom_modal_create_list.dart';
import 'package:shoppinglist/components/list_titles.dart';
import 'package:shoppinglist/screens/finished_lists_screen.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';

class BottomBar extends StatefulWidget {
  final Future<void> Function() refreshLists;
  const BottomBar({super.key, required this.refreshLists});

  @override
  State<BottomBar> createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      ListTitles(refreshLists: widget.refreshLists),
      const MyConnectionsScreen(),
      const FinishedListsScreen(),
    ];

    void onTabTapped(int index) {
      if (index == 1) {
        showModalBottomSheet(
          context: context,
          builder: (context) => BottomModalCreateList(
            onListCreated: widget.refreshLists,
          ),
        );
      } else {
        setState(() {
          _currentIndex = index >= 2 ? index - 1 : index;
        });
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: children[_currentIndex],
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: const Color.fromARGB(255, 20, 67, 117),
          items: const [
            TabItem(icon: Icons.home, title: 'עמוד הבית'),
            TabItem(icon: Icons.add, title: 'רשימה חדשה'),
            TabItem(icon: Icons.people_alt, title: 'אנשי הקשר שלי'),
            TabItem(icon: Icons.history, title: 'היסטוריית רשימות'),
          ],
          initialActiveIndex: _currentIndex,
          onTap: onTabTapped,
          height: 70,
        ),
      ),
    );
  }
}
