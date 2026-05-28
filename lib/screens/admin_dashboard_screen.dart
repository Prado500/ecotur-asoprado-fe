import 'package:flutter/material.dart';
import '../widgets/grid_pattern_painter.dart';
import '../widgets/stat_card.dart';
import '../widgets/admin_bottom_nav_bar.dart';
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
          Positioned.fill(
            child: CustomPaint(painter: GridPatternPainter()),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
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

                  const StatCard(
                    title: 'PAQUETES ACTIVOS',
                    value: '124',
                    status: '+12%',
                    icon: Icons.inventory_2_outlined,
                  ),
                  const StatCard(
                    title: 'RESERVAS PENDIENTES',
                    value: '38',
                    status: 'Requiere acción',
                    icon: Icons.confirmation_number_outlined,
                    isPositive: false,
                  ),
                  const StatCard(
                    title: 'CONVERSIÓN',
                    value: '24%',
                    status: 'Óptimo',
                    icon: Icons.trending_up,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // --- AQUÍ INYECTAMOS EL NUEVO COMPONENTE ---
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: AdminBottomNavBar(currentIndex: 0),
          ),
        ],
      ),
    );
  }
}