import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../models/tourist_service_model.dart';
import '../view_models/admin_create_package_viewmodel.dart';
import '../widgets/admin/admin_section_card.dart';
import '../widgets/admin/admin_form_field.dart';
import '../utils/ui_helpers.dart';
import '../utils/currency_formatter.dart';

/// Dumb View rendering the unified package creation/edition layout.
/// Leverages Eager Uploading: Local files are immediately staged to the CDN,
/// allowing a single interactive Drag & Drop list for both Create and Edit modes.
class AdminCreatePackageScreen extends StatefulWidget {
  final CatalogService? catalogService;
  final TouristService? serviceToEdit;

  const AdminCreatePackageScreen({super.key, this.catalogService, this.serviceToEdit});

  @override
  State<AdminCreatePackageScreen> createState() => _AdminCreatePackageScreenState();
}

class _AdminCreatePackageScreenState extends State<AdminCreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AdminCreatePackageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminCreatePackageViewModel(
      widget.catalogService ?? CatalogService(),
      serviceToEdit: widget.serviceToEdit,
    );
    _viewModel.addListener(_onViewModelChange);
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      _viewModel.clearError();
    }

    if (_viewModel.isSuccess) {
      final successMsg = _viewModel.isEditMode ? '¡Paquete actualizado exitosamente!' : '¡Paquete creado exitosamente!';
      UIHelpers.showSnackBar(context, successMsg, isError: false);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_viewModel.isEditMode) {
      _showConfirmationDialog();
    } else {
      _viewModel.savePackage();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Confirmar Actualización', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
          content: const Text('¿Estás seguro de que deseas guardar los cambios realizados en este paquete? Esta acción modificará los datos en el sistema.', style: TextStyle(color: Color(0xFF3B494C))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: Color(0xFF6B7A7D))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _viewModel.updatePackage();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006875)),
              child: const Text('SÍ, ACTUALIZAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF3B494C)), onPressed: () => Navigator.pop(context)),
        title: Text(_viewModel.isEditMode ? 'EDITAR PAQUETE' : 'CREAR NUEVO PAQUETE', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AdminSectionCard(
                title: 'DATOS MAESTROS DEL PAQUETE',
                dotColor: const Color(0xFF006875),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminFormField(
                      label: 'NOMBRE DEL PAQUETE',
                      hint: 'Ej. Ruta de la Cascada Prado',
                      controller: _viewModel.nameController,
                      validator: (value) {
                        if (value == null || value.trim().length < 20) return 'Mínimo 20 caracteres (Ej: Tour Cascada la Encantada)';
                        if (value.trim().length > 65) return 'Máximo 65 caracteres permitidos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('CATEGORÍA', style: TextStyle(fontSize: 12, color: Color(0xFF3B494C), fontWeight: FontWeight.bold)),
                    ),
                    ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBAC9CC)), borderRadius: BorderRadius.circular(4)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _viewModel.selectedCategory,
                                items: ['agroturismo', 'recreacional', 'metalmecanico', 'otro'].map((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
                                }).toList(),
                                onChanged: (val) => _viewModel.setCategory(val!),
                              ),
                            ),
                          );
                        }
                    ),
                    const SizedBox(height: 16),
                    AdminFormField(
                      label: 'DESCRIPCIÓN DEL PAQUETE',
                      hint: 'Detalle exhaustivo de la experiencia...',
                      controller: _viewModel.descriptionController,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().length < 20) return 'La descripción debe tener al menos 20 caracteres';
                        if (value.trim().length > 1000) return 'Máximo 1000 caracteres';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AdminSectionCard(
                title: 'PARÁMETROS DE CAPACIDAD Y SERVICIO',
                dotColor: const Color(0xFF6834D1),
                content: AdminFormField(
                  label: 'CAPACIDAD MÁXIMA DE TURISTAS',
                  hint: 'Ej. 15',
                  controller: _viewModel.capacityController,
                  isNumeric: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final number = int.tryParse(value.trim());
                    if (number == null || number <= 0 || number > 30) return 'La capacidad debe ser entre 1 y 30 personas';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              AdminSectionCard(
                title: 'FINANZAS Y RECURSOS MULTIMEDIA',
                dotColor: const Color(0xFF006C49),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminFormField(
                      label: 'PRECIO BASE (COP)',
                      hint: 'Ej. 85.000',
                      controller: _viewModel.priceController,
                      isNumeric: true,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        final cleanValue = value.replaceAll('.', '').trim();
                        final number = double.tryParse(cleanValue);
                        if (number == null || number < 40000) return 'El precio mínimo permitido es \$40.000 COP';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('IMÁGENES DEL PAQUETE', style: TextStyle(fontSize: 12, color: Color(0xFF3B494C), fontWeight: FontWeight.bold)),
                    ),
                    ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, child) {
                          // ==========================================
                          // UNIFIED EAGER UPLOADING UI: Interactive Drag & Drop for BOTH modes
                          // ==========================================
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_viewModel.selectedImagesUrls.isNotEmpty)
                                SizedBox(
                                  height: 300,
                                  child: ReorderableListView.builder(
                                    buildDefaultDragHandles: false,
                                    itemCount: _viewModel.selectedImagesUrls.length,
                                    // Bloquear reordenamiento si se están subiendo imágenes
                                    onReorder: _viewModel.isUploadingImages ? (o, n) {} : _viewModel.reorderImages,
                                    itemBuilder: (context, index) {
                                      final url = _viewModel.selectedImagesUrls[index];
                                      final fileName = url.split('/').last;
                                      final isTemporal = url.contains('temp-ecotur-images');

                                      return Container(
                                        key: ValueKey(url),
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: index == 0 ? const Color(0xFF006C49) : const Color(0xFFBAC9CC),
                                              width: index == 0 ? 2 : 1
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (!_viewModel.isUploadingImages)
                                                ReorderableDragStartListener(
                                                  index: index,
                                                  child: const Icon(Icons.drag_indicator, color: Color(0xFF6B7A7D)),
                                                ),
                                              const SizedBox(width: 8),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.network(
                                                  url,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                          title: Text(
                                              fileName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal, fontSize: 12)
                                          ),
                                          subtitle: Text(
                                              index == 0
                                                  ? 'PORTADA PRINCIPAL'
                                                  : (isTemporal ? 'Nueva - Sin Guardar' : 'Alojada en CDN'),
                                              style: TextStyle(
                                                  color: index == 0 ? const Color(0xFF006C49) : const Color(0xFF6B7A7D),
                                                  fontSize: 10,
                                                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal
                                              )
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete_outline, color: _viewModel.isUploadingImages ? Colors.grey : const Color(0xFFBA1A1A)),
                                            onPressed: _viewModel.isUploadingImages ? null : () => _viewModel.removeImage(index),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _viewModel.isUploadingImages ? null : _viewModel.pickImages,
                                icon: _viewModel.isUploadingImages
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF006C49), strokeWidth: 2))
                                    : const Icon(Icons.cloud_upload_outlined, color: Color(0xFF006C49)),
                                label: Text(
                                    _viewModel.isUploadingImages ? 'SUBIENDO AL CDN TEMPORAL...' : 'SELECCIONAR IMÁGENES LOCALES',
                                    style: const TextStyle(color: Color(0xFF006C49), fontWeight: FontWeight.bold)
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  side: const BorderSide(color: Color(0xFF006C49), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                            ],
                          );
                        }
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          // Explicit use of .withValues() following modern Flutter Guidelines
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      return OutlinedButton(
                        onPressed: _viewModel.isUploadingImages ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFFBAC9CC))),
                        child: const Text('CANCELAR', style: TextStyle(color: Color(0xFF191C1E))),
                      );
                    }
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      final bool isLocked = _viewModel.isLoading || _viewModel.isUploadingImages;
                      return ElevatedButton.icon(
                        onPressed: isLocked ? null : _handleSubmit,
                        icon: _viewModel.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save, color: Colors.white, size: 18),
                        label: Text(_viewModel.isEditMode ? 'ACTUALIZAR' : 'GUARDAR', style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C49), padding: const EdgeInsets.symmetric(vertical: 16)),
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}