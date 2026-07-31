import 'package:ecotur_app/screens/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../models/tourist_service_model.dart';
import '../view_models/admin_kanban_viewmodel.dart';
import '../utils/ui_helpers.dart';
import '../widgets/admin/admin_bottom_nav_bar.dart';
import 'admin_create_package_screen.dart';
import 'catalog_screen.dart';

/// Dumb View rendering the Administrative Kanban Board.
/// Subscribes to [AdminKanbanViewModel] to dynamically paint columns.
class AdminKanbanScreen extends StatefulWidget {
  final String entityType; // 'paquetes' or 'usuarios'
  final CatalogService? catalogService;

  const AdminKanbanScreen({super.key, required this.entityType, this.catalogService});

  @override
  State<AdminKanbanScreen> createState() => _AdminKanbanScreenState();
}

class _AdminKanbanScreenState extends State<AdminKanbanScreen> {
  late final AdminKanbanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminKanbanViewModel(widget.catalogService ?? CatalogService());
    _viewModel.addListener(_onViewModelChange);
    _viewModel.loadKanbanBoard();
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      _viewModel.consumeMessages();
    }
    if (_viewModel.successMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.successMessage!, isError: false);
      _viewModel.consumeMessages();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  /// Triggers a generic Bottom Sheet modal mapping available operations
  void _openActionModal(TouristService service, String currentStatus) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACCIONES DE GESTIÓN', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B494C))),
                  const SizedBox(height: 8),
                  Text(service.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
                  const Divider(height: 32, color: Color(0xFFE2E8F0)),

                  if (currentStatus == 'activos') ...[
                    ListTile(
                      leading: const Icon(Icons.edit_outlined, color: Color(0xFF006875)),
                      title: const Text('Editar Detalles'),
                      onTap: () async {
                        Navigator.pop(context);
                        final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (context) => AdminCreatePackageScreen(serviceToEdit: service))
                        );
                        if (updated == true) _viewModel.loadKanbanBoard();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.pause_circle_outline, color: Color(0xFF6B7A7D)),
                      title: const Text('Desactivar (Mover a Por Activar)'),
                      onTap: () {
                        Navigator.pop(context);
                        _viewModel.mutatePackageState(service, PackageAction.deactivate);
                      },
                    ),
                  ] else if (currentStatus == 'inactivos') ...[
                    ListTile(
                      leading: const Icon(Icons.edit_outlined, color: Color(0xFF006875)),
                      title: const Text('Editar Detalles'),
                      onTap: () async {
                        Navigator.pop(context);
                        final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (context) => AdminCreatePackageScreen(serviceToEdit: service))
                        );
                        if (updated == true) _viewModel.loadKanbanBoard();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.play_circle_outline, color: Color(0xFF006C49)),
                      title: const Text('Activar (Publicar en Catálogo)'),
                      onTap: () {
                        Navigator.pop(context);
                        _viewModel.mutatePackageState(service, PackageAction.activate);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
                      title: const Text('Borrado Lógico (Mover a Eliminados)'),
                      onTap: () {
                        Navigator.pop(context);
                        _viewModel.mutatePackageState(service, PackageAction.softDelete);
                      },
                    ),
                  ] else if (currentStatus == 'eliminados') ...[
                    ListTile(
                      leading: const Icon(Icons.restore, color: Color(0xFF006875)),
                      title: const Text('Recuperar Paquete'),
                      onTap: () {
                        Navigator.pop(context);
                        _viewModel.mutatePackageState(service, PackageAction.recover);
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildKanbanColumn(String title, int count, List<TouristService> items, String columnType, {bool isAudit = false}) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
        border: Border.all(color: const Color(0xFFBAC9CC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBAC9CC))),
                child: Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B494C))),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isAudit
                ? Center(
                child: ElevatedButton.icon(
                  onPressed: () => UIHelpers.showSnackBar(context, 'Módulo de auditoría en construcción.', isError: false),
                  icon: const Icon(Icons.history, color: Colors.white, size: 18),
                  label: const Text('Ver Historial Completo', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006875), elevation: 0),
                )
            )
                : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildKanbanCard(items[index], columnType);
                }
            ),
          ),
          if (!isAudit)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: IconButton(
                icon: const Icon(Icons.search, size: 28, color: Color(0xFF3B494C)),
                onPressed: () => UIHelpers.showSnackBar(context, 'Módulo de búsqueda en construcción.', isError: false),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildKanbanCard(TouristService service, String columnType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191C1E)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          Text(service.category.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006875), letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _openActionModal(service, columnType),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('INSPECCIONAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF006875))),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPackage = widget.entityType == 'paquetes';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(isPackage ? 'GESTIÓN DE PAQUETES' : 'GESTIÓN DE USUARIOS', style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF3B494C)),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()))
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Top Operational Bar with safe overflow prevention (FittedBox + Expanded)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (isPackage) {
                            final created = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminCreatePackageScreen())
                            );
                            if (created == true) _viewModel.loadKanbanBoard();
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: FittedBox(child: Text(isPackage ? 'Crear Paquete' : 'Crear Usuario', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF006C49), elevation: 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CatalogScreen())),
                        icon: const Icon(Icons.public, color: Color(0xFF006875), size: 18),
                        label: FittedBox(child: Text(isPackage ? 'Catálogo Público' : 'Directorio', style: const TextStyle(color: Color(0xFF006875), fontWeight: FontWeight.w600))),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFF006875))),
                      ),
                    ),
                  ],
                ),
              ),

              // Kanban Board
              Expanded(
                child: ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      if (_viewModel.isLoading && _viewModel.activePackages.isEmpty && _viewModel.inactivePackages.isEmpty && _viewModel.deletedPackages.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF006875)));
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
                        child: Row(
                          children: [
                            _buildKanbanColumn('Auditar', 0, [], 'auditar', isAudit: true),
                            _buildKanbanColumn('Eliminados', _viewModel.deletedPackages.length, _viewModel.deletedPackages, 'eliminados'),
                            _buildKanbanColumn('Por Activar', _viewModel.inactivePackages.length, _viewModel.inactivePackages, 'inactivos'),
                            _buildKanbanColumn('Activos', _viewModel.activePackages.length, _viewModel.activePackages, 'activos'),
                          ],
                        ),
                      );
                    }
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AdminBottomNavBar(currentIndex: isPackage ? 1 : 2),
          ),
        ],
      ),
    );
  }
}