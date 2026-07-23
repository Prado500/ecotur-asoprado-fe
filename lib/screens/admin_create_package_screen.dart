import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../view_models/admin_create_package_viewmodel.dart';
import '../widgets/admin/admin_section_card.dart';
import '../widgets/admin/admin_form_field.dart';
import '../utils/ui_helpers.dart';

/// Dumb View rendering the administrative package creation layout.
/// Strictly observes [AdminCreatePackageViewModel] for dynamic rebuilds.
class AdminCreatePackageScreen extends StatefulWidget {
  final CatalogService? catalogService;

  const AdminCreatePackageScreen({super.key, this.catalogService});

  @override
  State<AdminCreatePackageScreen> createState() => _AdminCreatePackageScreenState();
}

class _AdminCreatePackageScreenState extends State<AdminCreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AdminCreatePackageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminCreatePackageViewModel(widget.catalogService ?? CatalogService());
    _viewModel.addListener(_onViewModelChange);
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      _viewModel.clearError();
    }

    if (_viewModel.isSuccess) {
      UIHelpers.showSnackBar(context, '¡Paquete creado exitosamente!', isError: false);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSaveSubmission() {
    if (!_formKey.currentState!.validate()) return;
    _viewModel.savePackage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF3B494C)), onPressed: () => Navigator.pop(context)),
        title: const Text('CREAR NUEVO PAQUETE', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
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
                      hint: 'Ej. Ruta de la Cascada',
                      controller: _viewModel.nameController,
                      validator: (value) {
                        if (value == null || value.trim().length < 4) {
                          return 'El nombre debe ser más descriptivo (mín. 4 letras)';
                        }
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
                      hint: 'Detalle exhaustivo...',
                      controller: _viewModel.descriptionController,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().length < 20) {
                          return 'La descripción es muy corta. Detalla mejor la experiencia.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ESTADO DE DISPONIBILIDAD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('Activa la visibilidad pública.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7A7D))),
                              ],
                            ),
                          ),
                          ListenableBuilder(
                              listenable: _viewModel,
                              builder: (context, child) {
                                return Switch(
                                  value: _viewModel.isAvailable,
                                  activeColor: const Color(0xFF006C49),
                                  onChanged: (val) => _viewModel.setAvailability(val),
                                );
                              }
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AdminSectionCard(
                title: 'PARÁMETROS DE CAPACIDAD Y SERVICIO',
                dotColor: const Color(0xFF6834D1),
                content: AdminFormField(
                  label: 'CAPACIDAD MÁX.',
                  hint: 'Ej. 15',
                  controller: _viewModel.capacityController,
                  isNumeric: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) return 'Debe ser mayor a 0';
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
                      hint: '\$ 0.00',
                      controller: _viewModel.priceController,
                      isNumeric: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) return 'Precio inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('ENLACES DE IMÁGENES PÚBLICAS', style: TextStyle(fontSize: 12, color: Color(0xFF3B494C), fontWeight: FontWeight.bold)),
                    ),

                    // --- REACTIVE DYNAMIC LIST BUILDER ---
                    ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, child) {
                          return Column(
                            children: [
                              ..._viewModel.imageUrlsControllers.asMap().entries.map((entry) {
                                int index = entry.key;
                                TextEditingController controller = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AdminFormField(
                                          label: '',
                                          hint: 'https://ejemplo.com/foto.jpg',
                                          controller: controller,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
                                        onPressed: () => _viewModel.removeUrlField(index),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        }
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _viewModel.addUrlField,
                      icon: const Icon(Icons.add_link, color: Color(0xFF006C49)),
                      label: const Text('AGREGAR URL DE IMAGEN', style: TextStyle(color: Color(0xFF006C49), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFF006C49), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFFBAC9CC))),
                  child: const Text('CANCELAR', style: TextStyle(color: Color(0xFF191C1E))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      return ElevatedButton.icon(
                        onPressed: _viewModel.isLoading ? null : _handleSaveSubmission,
                        icon: _viewModel.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save, color: Colors.white, size: 18),
                        label: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
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