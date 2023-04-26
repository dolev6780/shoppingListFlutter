import 'package:flutter/material.dart';

List textSize = [
  {
    'm': 16,
  }
];

////////------------------------------tex

Widget txtInput(TextEditingController controller, String placeholder) {
  return TextField(
    textAlign: TextAlign.end,
    controller: controller,
    decoration: InputDecoration(
      hintText: placeholder,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
      ),
    ),
  );
}
