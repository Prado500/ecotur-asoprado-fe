import 'package:flutter/material.dart';
import '../widgets/common/grid_pattern_painter.dart';
import '../widgets/admin/stat_card.dart';
import '../widgets/admin/admin_bottom_nav_bar.dart';
import '../view_models/admin_dashboard_viewmodel.dart';
import '../utils/ui_helpers.dart';
import 'catalog_screen.dart';
import 'admin_create_package_screen.dart';

/// Dumb View rendering the Administrative Dashboard.
/// Observes the [AdminDashboardViewModel] to reactively display KPIs.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminDashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminDashboardViewModel();
    _viewModel.addListener(_onViewModelChange);

    // Trigger initial data load
    _viewModel.loadDashboardStats();
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

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

                  // --- REACTIVE KPI CARDS BOUND TO VIEWMODEL ---
                  ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        if (_viewModel.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: Color(0xFF006875)),
                          );
                        }

                        return Column(
                          children: [
                            StatCard(
                              title: 'PAQUETES ACTIVOS',
                              value: _viewModel.activePackages,
                              status: '+12%',
                              icon: Icons.inventory_2_outlined,
                            ),
                            StatCard(
                              title: 'RESERVAS PENDIENTES',
                              value: _viewModel.pendingReservations,
                              status: 'Requiere acción',
                              icon: Icons.confirmation_number_outlined,
                              isPositive: false,
                            ),
                            StatCard(
                              title: 'CONVERSIÓN',
                              value: _viewModel.conversionRate,
                              status: 'Óptimo',
                              icon: Icons.trending_up,
                            ),
                          ],
                        );
                      }
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: AdminBottomNavBar(currentIndex: 0),
          ),
        ],
      ),
    );
  }
}