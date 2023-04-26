import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType {
  text,
  email,
  number,
  phone,
}

class TextInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final InputType inputType;
  const TextInputWidget(
      {super.key,
      required this.controller,
      required this.placeholder,
      required this.inputType});
  TextInputType _getKeyboardType(InputType inputType) {
    switch (inputType) {
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.number:
        return TextInputType.number;
      case InputType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: 20,
      keyboardType: _getKeyboardType(inputType),
      textAlign: TextAlign.end,
      controller: controller,
      decoration: InputDecoration(
        counterText: "",
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
}
