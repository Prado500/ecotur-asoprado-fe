import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // <-- ¡El superpoder de validación!

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _obscurePassword = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            widget.label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3B494C), letterSpacing: 0.5)
        ),
        const SizedBox(height: 8),
        TextFormField( // <-- Transformado para soportar FormState
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscurePassword : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator, // <-- Inyectamos la regla
          autovalidateMode: AutovalidateMode.onUserInteraction, // <-- Valida en tiempo real
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(widget.icon, color: const Color(0xFF6B7A7D)),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF6B7A7D)),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF006875), width: 2)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFBA1A1A))),
            focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: false,
          ),
        ),
      ],
    );
  }
}