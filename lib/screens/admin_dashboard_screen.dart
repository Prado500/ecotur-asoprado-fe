import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'admin_create_package_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Stack(
        children: [
          // Patrón de fondo
          Positioned.fill(child: CustomPaint(painter: GridPatternPainter())),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- TARJETA PRINCIPAL ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestión Centralizada\nde Ofertas Turísticas',
                          style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF191C1E), height: 1.2),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Administre, cree y supervise los paquetes turísticos disponibles para sus clientes. Mantenga el catálogo actualizado y atractivo.',
                          style: TextStyle(color: Color(0xFF3B494C), fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // Botón Crear
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCreatePackageScreen()));
                            },
                            icon: const Icon(Icons.add, color: Colors.white, size: 20),
                            label: const Text('Crear Nuevo Paquete Turístico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006875),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Botón Catálogo Público
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CatalogScreen()));
                            },
                            icon: const Icon(Icons.visibility, color: Color(0xFF006875), size: 20),
                            label: const Text('Ver Catálogo Público', style: TextStyle(color: Color(0xFF006875), fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF006875)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- ESTADÍSTICAS ---
                  _buildStatCard('PAQUETES ACTIVOS', '124', '+12%', Icons.inventory_2_outlined, true),
                  _buildStatCard('RESERVAS PENDIENTES', '38', 'Requiere acción', Icons.confirmation_number_outlined, false),
                  _buildStatCard('CONVERSIÓN', '24%', 'Óptimo', Icons.trending_up, true),

                  const SizedBox(height: 80), // Espacio para bottom nav
                ],
              ),
            ),
          ),

          // --- BOTTOM NAV BAR ---
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 24, top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'INICIO', true),
                  _buildNavItem(Icons.inventory_2_outlined, 'PAQUETES', false),
                  _buildNavItem(Icons.add_circle_outline, 'CREAR', false),
                  _buildNavItem(Icons.settings_outlined, 'AJUSTES', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String status, IconData icon, bool isPositive) {
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
          Icon(icon, size: 48, color: const Color(0xFFE2E8F0)), // Icono de agua
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D))),
      ],
    );
  }
}

// Reutilizamos el Grid Painter
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF006875).withOpacity(0.03)..strokeWidth = 1;
    const double spacing = 24.0;
    for (double i = 0; i < size.width; i += spacing) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += spacing) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}