import 'package:flutter/services.dart';

/// Formatter that injects Colombian Peso thousands separators (.) in real-time.
/// It intercepts user keystrokes to format inputs like '50000' into '50.000'.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Extract digits exclusively to prevent non-numeric characters from breaking the parse
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final formatted = _formatThousands(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Inserts dots every 3 digits from right to left using a string buffer.
  String _formatThousands(String digits) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}