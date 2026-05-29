import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final IconData icon;
  final bool isPositive;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3B494C), letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF191C1E), height: 1.0)),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: isPositive ? const Color(0xFF006C49) : const Color(0xFFBA1A1A)),
                      const SizedBox(width: 4),
                      Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isPositive ? const Color(0xFF006C49) : const Color(0xFFBA1A1A))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Icon(icon, size: 48, color: const Color(0xFFE2E8F0)),
        ],
      ),
    );
  }
}