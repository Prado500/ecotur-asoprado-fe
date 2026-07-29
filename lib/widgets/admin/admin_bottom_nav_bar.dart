import 'package:flutter/material.dart';
import '../../screens/admin_dashboard_screen.dart';
import '../../screens/admin_kanban_screen.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavBar({super.key, required this.currentIndex});

  Widget _buildAdminNavItem(BuildContext context, IconData icon, String label, int index, {VoidCallback? onTap}) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
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
      ),
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
          _buildAdminNavItem(context, Icons.home, 'INICIO', 0, onTap: () {
            if (currentIndex != 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
            }
          }),
          _buildAdminNavItem(context, Icons.inventory_2_outlined, 'PAQUETES', 1, onTap: () {
            if (currentIndex != 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminKanbanScreen(entityType: 'paquetes')));
            }
          }),
          _buildAdminNavItem(context, Icons.people_outline, 'USUARIOS', 2, onTap: () {
            if (currentIndex != 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminKanbanScreen(entityType: 'usuarios')));
            }
          }),
          _buildAdminNavItem(context, Icons.settings_outlined, 'AJUSTES', 3, onTap: () {
            // El menú de ajustes se maneja desde el action card principal por ahora
          }),
        ],
      ),
    );
  }
}