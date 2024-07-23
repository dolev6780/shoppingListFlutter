import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/screens/finished_lists_screen.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/screens/signin_screen.dart';
import 'package:shoppinglist/components/list_titles.dart';
import '../components/app_bar.dart';
import '../components/bottom_navigation.dart';
import 'package:shoppinglist/services/auth_service.dart';
import '../services/create_new_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final CreateNewList _createNewList = CreateNewList();
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (_currentIndex) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const MyConnectionsScreen(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const FinishedListsScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const SignInScreen();
    }

    String name = user.displayName ?? "";
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 34, 34),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(
          title: "הרשימות שלי",
          backBtn: false,
          color: Color.fromARGB(255, 20, 67, 117),
        ),
      ),
      endDrawer: Drawer(
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
                          backgroundColor:
                              const Color.fromARGB(255, 0, 119, 255),
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : user.email![0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        name.isNotEmpty
                            ? name
                            : user.email.toString()[0].toUpperCase() +
                                user.email.toString().substring(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                  ),
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
                            children: const [
                              Icon(Icons.history),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(Icons.people),
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute<void>(
                            //       builder: (BuildContext context) =>
                            //           const SettingScreen(),
                            //     ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(Icons.settings),
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
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),
                  name.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.all(10),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _authService.signOut();
                              });
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const SignInScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Icon(Icons.logout),
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
                child: Text("copyright 2023"),
              ),
            ],
          ),
        ),
      ),
      body: SizedBox(
        height: screenHeight - 100,
        child: const ListTitles(),
      ),
      bottomNavigationBar: GradientBottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'עמוד הבית',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'אנשי הקשר שלי',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'היסטוריית רשימות',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _createNewList.showAlertDialog(context),
          backgroundColor: const Color.fromARGB(255, 20, 67, 117),
          label: const Text("רשימה חדשה"),
          icon: const Icon(Icons.add),
          elevation: 0,
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;

  const GradientText({
    super.key,
    required this.text,
    required this.gradient,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
