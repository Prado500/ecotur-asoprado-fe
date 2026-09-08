import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_style.dart';

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
  bool _isFocused = false;

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
            style: AppTextStyles.inputLabel
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
            hintStyle: AppTextStyles.inputValue.copyWith(color: Colors.grey[400]),
            prefixIcon: Icon(widget.icon, color:_isFocused ? AppColors.accent : AppColors.iconInactive),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.iconInactive),
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