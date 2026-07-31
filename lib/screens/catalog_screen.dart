import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../services/session_service.dart';
import '../view_models/catalog_viewmodel.dart';
import '../widgets/common/grid_pattern_painter.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import '../widgets/catalog/tourist_card.dart';

/// Dumb View representing the tourist catalog.
/// Dynamically adjusts its entire layout (AppBar and BottomNav) based on the user's authenticated role
/// to preserve hierarchical navigation flows for Administrators.
class CatalogScreen extends StatefulWidget {
  final CatalogService? catalogService;
  final SessionService? sessionService;

  const CatalogScreen({super.key, this.catalogService, this.sessionService});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogViewModel _viewModel;
  late final SessionService _sessionService;

  @override
  void initState() {
    super.initState();
    final service = widget.catalogService ?? CatalogService();
    _sessionService = widget.sessionService ?? SessionService();
    _viewModel = CatalogViewModel(service);

    _sessionService.checkExistingSession();
    _viewModel.loadCatalog();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _sessionService,
        builder: (context, _) {
          final isAdmin = _sessionService.userRole == 'admin';

          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FB),
            body: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: GridPatternPainter()),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomAppBar(isAdmin),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SERVICIOS TURÍSTICOS',
                              style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006875), letterSpacing: -0.5),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Explora nuestra selección de experiencias únicas y descubre la belleza natural y cultural de la región.',
                              style: TextStyle(color: Color(0xFF3B494C), fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: _viewModel,
                          builder: (context, child) {
                            if (_viewModel.isLoading) {
                              return const Center(child: CircularProgressIndicator(color: Color(0xFF006875)));
                            }

                            if (_viewModel.errorMessage != null) {
                              return _buildErrorState(_viewModel.errorMessage!);
                            }

                            if (_viewModel.services.isEmpty) {
                              return const Center(child: Text('Aún no hay paquetes disponibles.'));
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              itemCount: _viewModel.services.length,
                              itemBuilder: (context, index) {
                                return TouristCard(service: _viewModel.services[index]);
                              },
                            );
                          },
                        ),
                      ),
                      // Only add bottom padding if the tourist bottom nav bar is going to be rendered
                      if (!isAdmin) const SizedBox(height: 80),
                    ],
                  ),
                ),

                // Dynamic Role-Aware Bottom Navigation Bar for tourists only
                if (!isAdmin)
                  const Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: CustomBottomNavBar(currentIndex: 0),
                  ),
              ],
            ),
          );
        }
    );
  }

  /// Mutates the AppBar dynamically. Renders a back arrow for Admins to prevent stack trapping.
  Widget _buildCustomAppBar(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isAdmin
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3B494C)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
              : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.menu, color: Color(0xFF00DAF3)),
          ),
          Text(
            isAdmin ? 'CATÁLOGO PÚBLICO' : 'ECOTUR ASOPRADO',
            style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF191C1E)),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFBA1A1A)),
            const SizedBox(height: 16),
            Text(errorText, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF3B494C))),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => _viewModel.loadCatalog(), child: const Text('Reintentar'))
          ],
        ),
      ),
    );
  }
}