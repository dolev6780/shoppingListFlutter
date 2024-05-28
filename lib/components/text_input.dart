import 'package:flutter/material.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        maxLength: 20,
        keyboardType: _getKeyboardType(inputType),
        textAlign: TextAlign.start,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(15),
          counterText: "",
          hintText: placeholder,
          label: Text(placeholder),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 0, 142),
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
