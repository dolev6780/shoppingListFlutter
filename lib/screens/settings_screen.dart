import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/app_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shoppinglist/screens/privacy.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = "";
  String _connectId = "";
  final List<Color> _colors = [
    const Color.fromARGB(255, 20, 67, 117),
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.tealAccent,
  ];
  Color _currentColor = const Color.fromARGB(255, 20, 67, 117);
  bool _expanded = false;
  bool _nightMode = false;
  @override
  void initState() {
    super.initState();
    _getName();
  }

  Future<void> _getName() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = Provider.of<User?>(context, listen: false);

      if (user != null) {
        final DocumentSnapshot documentSnapshot =
            await firestore.collection('users').doc(user.uid).get();

        if (documentSnapshot.exists) {
          setState(() {
            _userName = documentSnapshot['displayName'];
            _connectId = documentSnapshot['connectId'];
          });
        } else {
          // Handle the case when the document does not exist
        }
      } else {}
    } catch (e) {
      // Handle error (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<User?>(context);
    String name = _userName;
    Color color = _currentColor;
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(
          title: "הגדרות",
          backBtn: true,
          color: color,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                      maxRadius: 40,
                      backgroundColor: color,
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : user?.email?.toString()[0].toUpperCase() ?? '',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    user!.email.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, indent: 50, endIndent: 50, color: color),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Share.share(_connectId);
                        },
                        icon: const Icon(Icons.share)),
                    const Text(
                      ":המזהה שלך",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: color),
            const SizedBox(height: 10),
            const Text("תצוגה",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _expanded ? 220.0 : 24.0,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(_colors.length, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentColor = _colors[index];
                                    });
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _colors[index],
                                      shape: BoxShape.circle,
                                      border: _currentColor == _colors[index]
                                          ? Border.all(
                                              color: Colors.black, width: 2.0)
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expanded = !_expanded;
                              });
                            },
                            child: !_expanded
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : Icon(
                                    Icons.close,
                                    color: _currentColor,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "בחר צבע ערכת נושא",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.sunny,
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  value: _nightMode,
                  onChanged: (value) => {
                    setState(() {
                      _nightMode = !_nightMode;
                    })
                  },
                  activeTrackColor: color,
                ),
                Row(
                  children: [
                    const Text(
                      "מצב לילה",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.nightlight,
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: color),
            const SizedBox(height: 10),
            const Text("אודות",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Directionality(
              textDirection: TextDirection.rtl,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const Privacy(),
                    ),
                  );
                },
                title: const Text("פרטיות"),
              ),
            ),
            const Directionality(
              textDirection: TextDirection.rtl,
              child: ListTile(
                title: Text("גירסה"),
                subtitle: Text("1.0"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
