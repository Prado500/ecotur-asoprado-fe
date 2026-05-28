import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, {VoidCallback? onTap}) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF006C49).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D)),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.explore, 'Catálogo', 0),
          _buildNavItem(context, Icons.confirmation_number_outlined, 'Reservas', 1),
          _buildNavItem(context, Icons.map_outlined, 'Mapa', 2),
          _buildNavItem(context, Icons.person_outline, 'Perfil', 3, onTap: () {
            if (currentIndex != 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }
          }),
        ],
      ),
    );
  }
}