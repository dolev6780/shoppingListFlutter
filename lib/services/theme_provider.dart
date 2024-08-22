import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _themeColor = const Color.fromARGB(255, 20, 67, 117);

  ThemeMode get themeMode => _themeMode;
  Color get themeColor => _themeColor;

  ThemeData get currentTheme {
    return ThemeData(
      primaryColor: _themeColor,
      appBarTheme: AppBarTheme(color: _themeColor),
      brightness:
          _themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
    );
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveThemeModeToFirestore(_themeMode);
  }

  void setThemeColor(Color color) {
    _themeColor = color;
    notifyListeners();
    _saveThemeColorToFirestore(color);
  }

  Future<void> _saveThemeModeToFirestore(ThemeMode mode) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String modeString = mode == ThemeMode.light ? 'light' : 'dark';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'themeMode': modeString});
      }
    } catch (e) {
      // Handle errors
      debugPrint("Error saving theme mode: $e");
    }
  }

  Future<void> _saveThemeColorToFirestore(Color color) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String colorHex =
            '#${color.value.toRadixString(16).substring(2).padLeft(6, '0')}';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'themeColor': colorHex});
      }
    } catch (e) {
      // Handle errors
      debugPrint("Error saving theme color: $e");
    }
  }

  Future<void> loadThemeColorAndMode() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot documentSnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (documentSnapshot.exists) {
          if (documentSnapshot['themeColor'] != null) {
            final String colorHex = documentSnapshot['themeColor'];
            _themeColor = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
          }
          if (documentSnapshot['themeMode'] != null) {
            final String modeString = documentSnapshot['themeMode'];
            _themeMode =
                modeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle errors
      debugPrint("Error loading theme color and mode: $e");
    }
  }
}
