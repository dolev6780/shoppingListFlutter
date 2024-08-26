import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/app_bar.dart';
import 'package:shoppinglist/screens/privacy_screen.dart';
import 'package:shoppinglist/services/auth_provider.dart';
import 'package:shoppinglist/services/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Color> _colors = [
    const Color.fromARGB(255, 20, 67, 117),
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    const Color.fromARGB(255, 14, 196, 154),
  ];
  Color _currentColor = const Color.fromARGB(255, 20, 67, 117);
  bool _nightMode = false;

  @override
  void initState() {
    super.initState();

    _loadNightModeSetting();
  }

  void _loadNightModeSetting() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _nightMode = themeProvider.themeMode == ThemeMode.dark;
    });
  }

  void _showColorPickerDialog() {
    Color tempColor = _currentColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('בחר צבע ערכת נושא',
              textDirection: TextDirection.rtl, style: TextStyle(fontSize: 20)),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentColor = color;
                    });
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setThemeColor(color);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _currentColor == color
                          ? Border.all(color: Colors.black, width: 2.0)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => {
                setState(() {
                  _currentColor = tempColor;
                }),
                Provider.of<ThemeProvider>(context, listen: false)
                    .setThemeColor(_currentColor),
                Navigator.pop(context),
              },
              child: const Text(
                'ביטול',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'אישור',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final User? user = Provider.of<User?>(context);

    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;

    String? displayName = context.watch<AuthProviding>().displayName;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(
          title: "הגדרות",
          color: themeColor,
          homeBtn: true,
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
                      backgroundColor: themeColor,
                      child: Text(
                        displayName!.isNotEmpty
                            ? displayName[0].toUpperCase()
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
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user!.email.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, indent: 50, endIndent: 50, color: themeColor),
            const SizedBox(height: 10),
            const Text("תצוגה",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _showColorPickerDialog,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "בחר צבע ערכת נושא",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.sunny,
                      color: themeColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  value: _nightMode,
                  onChanged: (value) {
                    setState(() {
                      _nightMode = value;
                    });
                    themeProvider.toggleTheme();
                  },
                  activeTrackColor: themeColor,
                  inactiveThumbColor: themeColor,
                  activeColor: Colors.white,
                ),
                Row(
                  children: [
                    const Text(
                      "מצב לילה",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.nightlight,
                      color: themeColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: themeColor),
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
                      builder: (BuildContext context) =>
                          const PrivacyPolicyScreen(),
                    ),
                  );
                },
                title: const Text(
                  "פרטיות",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const Directionality(
              textDirection: TextDirection.rtl,
              child: ListTile(
                title: Text(
                  "גירסה",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                subtitle: Text(
                  "1.0",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
