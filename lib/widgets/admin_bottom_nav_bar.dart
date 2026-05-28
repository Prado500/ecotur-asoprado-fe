import 'package:flutter/material.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavBar({super.key, required this.currentIndex});

  Widget _buildAdminNavItem(IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D)),
        const SizedBox(height: 4),
        Text(
            label,
            style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D)
            )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAdminNavItem(Icons.home, 'INICIO', 0),
          _buildAdminNavItem(Icons.inventory_2_outlined, 'PAQUETES', 1),
          _buildAdminNavItem(Icons.add_circle_outline, 'CREAR', 2),
          _buildAdminNavItem(Icons.settings_outlined, 'AJUSTES', 3),
        ],
      ),
    );
  }
}