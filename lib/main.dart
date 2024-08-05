import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/services/auth_provider.dart';
import 'package:shoppinglist/services/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProviding>(
          create: (_) => AuthProviding(),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<AuthProviding>().authStateChanges,
          initialData: null,
        ),
      ],
      child: const MaterialApp(
        title: 'List',
        home: Wrapper(),
      ),
    );
  }
}
