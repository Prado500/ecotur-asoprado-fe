import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../view_models/catalog_viewmodel.dart';
import '../widgets/common/grid_pattern_painter.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import '../widgets/catalog/tourist_card.dart';

/// Dumb View representing the tourist catalog.
/// It completely delegates state tracking and data fetching to its [CatalogViewModel].
class CatalogScreen extends StatefulWidget {
  final CatalogService? catalogService;

  const CatalogScreen({super.key, this.catalogService});

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Resolving dependencies symmetrically through the designated layers
    final service = widget.catalogService ?? CatalogService();
    _viewModel = CatalogViewModel(service);

    // Fire-and-forget invocation decoupled from full view rendering pipelines
    _viewModel.loadCatalog();
  }

  @override
  void dispose() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomAppBar(),
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
                  // --- REACTIVE PRESENTATION BINDING ---
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
                const SizedBox(height: 80),
              ],
            ),
          ),
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: CustomBottomNavBar(currentIndex: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.menu, color: Color(0xFF00DAF3)),
          ),
          const Text(
            'ECOTUR ASOPRADO',
            style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF191C1E)),
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
            Text(
              errorText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF3B494C)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _viewModel.loadCatalog(),
              child: const Text('Reintentar'),
            )
          ],
        ),
      ),
    );
  }
}