import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/screens/create_list_screen.dart';
import 'package:shoppinglist/screens/finished_lists_screen.dart';
import 'package:shoppinglist/screens/my_connections_screen.dart';
import 'package:shoppinglist/screens/signin_screen.dart';
import 'package:shoppinglist/components/list_titles.dart';
import '../components/app_bar.dart';
import '../components/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String? _email = "";
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
            ));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const FinishedListsScreen(),
            ));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (!(_user?.email == null)) {
      _email = _user?.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Appbar(
            title: "!ברוכים הבאים",
            backBtn: false,
          )),
      endDrawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50, 30, 50, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  _email!.isEmpty
                      ? Container(
                          margin: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color.fromARGB(255, 0, 140, 255),
                                  Color.fromARGB(255, 0, 64, 255),
                                ]),
                                borderRadius: BorderRadius.circular(8)),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            const SignInScreen(),
                                      ));
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: const <Widget>[
                                    Icon(Icons.login_rounded,
                                        color: Colors.white),
                                    Text(
                                      "התחברות",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                )),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 5),
                                CircleAvatar(
                                    maxRadius: 18,
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 119, 255),
                                    child: Text(
                                      _email!.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    )),
                              ],
                            ),
                            const GradientText(
                              text: "!ברוכים הבאים",
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue,
                                  Color.fromARGB(255, 0, 30, 255)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            )
                          ],
                        ),
                  Container(
                    height: 10,
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
                                  ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Icon(Icons.history),
                                Text(
                                  "הסטוריית רשימות",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const MyConnectionsScreen(),
                                  ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Icon(Icons.people),
                                Text(
                                  "אנשי הקשר שלי",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )),
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
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            _auth.signOut();
                            _email = "";
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const HomeScreen(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.logout),
                            Text(
                              "התנתקות",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        )),
                  ),
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
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 74, 167, 243),
              Color.fromARGB(255, 22, 115, 228)
            ], // List of colors for the gradient
            begin: Alignment.centerLeft, // Starting point of the gradient
            end: Alignment.centerRight, // Ending point of the gradient
          ),
          borderRadius: BorderRadius.circular(20.0), // Optional border radius
          boxShadow: const [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset:
                  Offset(0, 2), // Horizontal and vertical offset of the shadow
              blurRadius: 4.0, // Spread radius of the shadow
              spreadRadius:
                  0.0, // Extent of the shadow (positive values expand the shadow, negative values shrink it)
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const CreateListScreen(),
              ),
            );
          },
          label: const Text("רשימה חדשה"),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.transparent,
          elevation: 0,
          splashColor: Colors.blue,
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
