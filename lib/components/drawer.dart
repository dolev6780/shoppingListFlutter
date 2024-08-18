import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/screens/contact_us.dart';
import 'package:shoppinglist/screens/finished_lists_screen.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/screens/settings_screen.dart';
import 'package:shoppinglist/screens/signin_screen.dart';
import 'package:shoppinglist/services/theme_provider.dart';
import '../services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();
  final String userName;

  CustomDrawer({super.key, required this.userName});

  Future<void> _signOut(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const SignInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Color themeColor = themeProvider.themeColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color btnColor = isDarkMode ? Colors.white : Colors.black;
    String name = userName;

    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(50, 70, 50, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 5),
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(50),
                      child: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: themeColor,
                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : user?.email.toString()[0].toUpperCase() ?? "",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name.isNotEmpty
                          ? name
                          : user!.email.toString()[0].toUpperCase() +
                              user.email.toString().substring(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(height: 20),
                const Divider(height: 1, thickness: 1),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const FinishedListsScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.history, color: themeColor),
                            Text(
                              "הסטוריית רשימות",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: btnColor),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const MyConnectionsScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.people, color: themeColor),
                            Text(
                              "אנשי הקשר שלי",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: btnColor),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const SettingsScreen(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.settings, color: themeColor),
                            Text(
                              "הגדרות",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: btnColor),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const ContactUs(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.email_outlined, color: themeColor),
                            Text(
                              "יצירת קשר",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: btnColor),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const SettingsScreen(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.star, color: themeColor),
                            Text(
                              "דרג.י אותנו",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: btnColor),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const SettingsScreen(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.share, color: themeColor),
                            Text(
                              "שיתוף",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: btnColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                user?.email?.isNotEmpty ?? false
                    ? Container(
                        margin: const EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: () => _signOut(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.logout, color: themeColor),
                              Text(
                                "התנתקות",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: btnColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Text(""),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "copyright 2023",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
