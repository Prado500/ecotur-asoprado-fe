import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isNumeric;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const AdminFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isNumeric = false,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF3B494C), fontWeight: FontWeight.bold)),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBAC9CC)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBAC9CC)), borderRadius: BorderRadius.circular(4)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF006875)), borderRadius: BorderRadius.circular(4)),
            errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBA1A1A)), borderRadius: BorderRadius.circular(4)),
            focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBA1A1A)), borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }
}