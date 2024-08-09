import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/components/app_bar.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = "";
  String _connectId = "";

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

    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(
          title: "הגדרות",
          backBtn: true,
          color: Color.fromARGB(255, 20, 67, 117),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 20),
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
                      backgroundColor: const Color.fromARGB(255, 20, 67, 117),
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
            const Divider(
                height: 1,
                indent: 50,
                endIndent: 50,
                color: Color.fromARGB(255, 20, 67, 117)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IconButton(
                //   icon: const Icon(Icons.copy,
                //       size: 20, color: Color.fromARGB(255, 20, 67, 117)),
                //   onPressed: () {
                //     Clipboard.setData(ClipboardData(text: _connectId));
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //           content: Text(
                //             'הועתק ללוח',
                //             textAlign: TextAlign.right,
                //           ),
                //           backgroundColor: Color.fromARGB(255, 20, 67, 117)),
                //     );
                //   },
                // ),
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
            const Divider(
                height: 1,
                indent: 50,
                endIndent: 50,
                color: Color.fromARGB(255, 20, 67, 117)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
