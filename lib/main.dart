import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoppinglist/services/auth_provider.dart';
import 'package:shoppinglist/services/theme_provider.dart';
import 'package:shoppinglist/services/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create an instance of ThemeProvider to load the theme color
  final themeProvider = ThemeProvider();
  await themeProvider
      .loadThemeColorAndMode(); // Load theme color before app starts

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
        ChangeNotifierProvider<AuthProviding>(
          create: (_) => AuthProviding(),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<AuthProviding>().authStateChanges,
          initialData: null,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'List',
          theme: themeProvider.currentTheme,
          home: const Wrapper(),
        );
      },
    );
  }
}
