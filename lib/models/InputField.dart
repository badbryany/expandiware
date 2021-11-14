import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keaboardType,
  }) : super(key: key);

  final TextEditingController controller;
  final TextInputType? keaboardType;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        color: Color(0x99202020),
      ),
      child: Center(
        child: TextFormField(
          autocorrect: false,
          controller: controller,
          keyboardType: keaboardType,
          decoration: InputDecoration(
            labelText: labelText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
