import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/audit_log_model.dart';
import '../services/audit_service.dart';
import '../view_models/audit_viewmodel.dart';

/// Dumb View rendering the Paginated Audit Trail.
/// Strictly observes [AuditViewModel] and utilizes a [ScrollController]
/// to trigger Infinite Scroll data fetching.
class AuditLogScreen extends StatefulWidget {
  final AuditService? auditService;

  const AuditLogScreen({super.key, this.auditService});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  late final AuditViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  // Filter controllers
  String? _selectedEntity;
  final TextEditingController _entityIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = AuditViewModel(widget.auditService ?? AuditService());
    _viewModel.addListener(_onViewModelChange);

    // Attach listener for Infinite Scroll
    _scrollController.addListener(_onScroll);

    // Initial fetch
    _viewModel.loadLogs();
  }

  void _onScroll() {
    // If we are 200 pixels near the bottom, fetch the next chunk
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMoreLogs();
    }
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entityIdController.dispose();
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // Hides keyboard on search
    FocusScope.of(context).unfocus();
    _viewModel.loadLogs(
      entityName: _selectedEntity,
      entityId: _entityIdController.text.trim(),
    );
  }

  /// Opens a BottomSheet to display the complex JSON delta.
  void _showChangesModal(AuditLogModel log) {
    if (log.changes == null || log.changes!.isEmpty) return;

    // Pretty-print the JSON Map
    final prettyJson = const JsonEncoder.withIndent('  ').convert(log.changes);

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
                Text('PAYLOAD DEL EVENTO', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B494C))),
                const SizedBox(height: 8),
                Text('${log.action} sobre ${log.entityName} #${log.entityId}', style: const TextStyle(fontSize: 14, color: Color(0xFF191C1E))),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        prettyJson,
                        style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF6CF8BB), fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'CREATE': return const Color(0xFF006C49);
      case 'UPDATE': return const Color(0xFF006875);
      case 'SOFT_DELETE': return const Color(0xFFBA1A1A);
      case 'RECOVER': return const Color(0xFF6834D1);
      default: return const Color(0xFF6B7A7D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('HISTORIAL DE AUDITORÍA', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C1E))),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF3B494C)), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // --- FILTER SECTION ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedEntity,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    hint: const Text('Entidad'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(value: 'User', child: Text('Usuarios')),
                      DropdownMenuItem(value: 'TouristService', child: Text('Paquetes')),
                    ],
                    onChanged: (val) => setState(() => _selectedEntity = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _entityIdController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                      hintText: 'ID / Cédula',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006875), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  child: const Icon(Icons.search, color: Colors.white),
                )
              ],
            ),
          ),

          // --- LIST SECTION ---
          Expanded(
            child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  if (_viewModel.isLoading && _viewModel.logs.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF006875)));
                  }

                  if (_viewModel.logs.isEmpty) {
                    return const Center(child: Text('No hay registros de auditoría que coincidan con la búsqueda.'));
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF006875),
                    onRefresh: () => _viewModel.loadLogs(entityName: _selectedEntity, entityId: _entityIdController.text.trim()),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _viewModel.logs.length + (_viewModel.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Render the bottom spinner if fetching more
                        if (index == _viewModel.logs.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator(color: Color(0xFF006875))),
                          );
                        }

                        final log = _viewModel.logs[index];
                        final actionColor = _getActionColor(log.action);

                        // Format DateTime securely
                        final localTime = log.timestamp.toLocal();
                        final formattedDate = "${localTime.day}/${localTime.month}/${localTime.year} ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: actionColor.withOpacity(0.1),
                              child: Icon(Icons.history, color: actionColor),
                            ),
                            title: Row(
                              children: [
                                Text(log.action, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: actionColor)),
                                const SizedBox(width: 8),
                                Expanded(child: SelectableText('${log.entityName} #${log.entityId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                SelectableText('Ejecutado por: ${log.performedBy}', style: const TextStyle(fontSize: 12, color: Color(0xFF3B494C))),
                                Text(formattedDate, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7A7D))),
                              ],
                            ),
                            trailing: log.changes != null && log.changes!.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.data_object, color: Color(0xFF006875)),
                              tooltip: 'Ver Cambios',
                              onPressed: () => _showChangesModal(log),
                            )
                                : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}