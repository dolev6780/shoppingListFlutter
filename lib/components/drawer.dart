import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/screens/contact_us.dart';
import 'package:shoppinglist/screens/finished_lists_screen.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/screens/settings_screen.dart';
import 'package:shoppinglist/screens/signin_screen.dart';
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
    String name = userName;
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    return Drawer(
      backgroundColor: Colors.white,
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
                        backgroundColor: const Color.fromARGB(255, 20, 67, 117),
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
                          fontWeight: FontWeight.bold, color: Colors.black),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.history,
                                color: Color.fromARGB(255, 20, 67, 117)),
                            Text(
                              "הסטוריית רשימות",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.people,
                                color: Color.fromARGB(255, 20, 67, 117)),
                            Text(
                              "אנשי הקשר שלי",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.settings,
                                color: Color.fromARGB(255, 20, 67, 117)),
                            Text(
                              "הגדרות",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.email_outlined,
                                color: Color.fromARGB(255, 20, 67, 117)),
                            Text(
                              "יצירת קשר",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.star,
                                color: Color.fromARGB(255, 20, 67, 117)),
                            Text(
                              "דרג.י אותנו",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.share,
                                color: Color.fromARGB(255, 20, 67, 117)),
                            Text(
                              "שיתוף",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.logout,
                                  color: Color.fromARGB(255, 20, 67, 117)),
                              Text(
                                "התנתקות",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
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
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
