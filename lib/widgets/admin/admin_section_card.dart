import 'package:flutter/material.dart';

class AdminSectionCard extends StatelessWidget {
  final String title;
  final Color dotColor;
  final Widget content;

  const AdminSectionCard({
    super.key,
    required this.title,
    required this.dotColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: dotColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFE2E8F0)),
          content,
        ],
      ),
    );
  }
}