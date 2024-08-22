import 'package:flutter/material.dart';

class ColorsService {
  Color? parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      return colorString.startsWith('#')
          ? Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000)
          : Color(int.parse(colorString));
    } catch (e) {
      return null;
    }
  }
}
