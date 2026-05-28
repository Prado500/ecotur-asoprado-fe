import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/admin/admin_section_card.dart';
import '../widgets/admin/admin_form_field.dart';
import '../utils/ui_helpers.dart';

class AdminCreatePackageScreen extends StatefulWidget {
  const AdminCreatePackageScreen({super.key});

  @override
  _AdminCreatePackageScreenState createState() => _AdminCreatePackageScreenState();
}

class _AdminCreatePackageScreenState extends State<AdminCreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final List<TextEditingController> _imageUrlsControllers = [];

  String _selectedCategory = 'metalmecanico';
  bool _isAvailable = true;
  bool _isLoading = false;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    for (var controller in _imageUrlsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _savePackage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    List<String> urlsList = _imageUrlsControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final packageData = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "category": _selectedCategory,
      "base_price": double.tryParse(_priceController.text) ?? 0.0,
      "max_capacity": int.tryParse(_capacityController.text) ?? 1,
      "is_available": _isAvailable,
      "image_urls": urlsList,
    };

    final result = await _apiService.createService(packageData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      UIHelpers.showSnackBar(context, '¡Paquete creado exitosamente!', isError: false);
      Navigator.pop(context);
    } else {
      UIHelpers.showSnackBar(context, result['message'], isError: true);
    }
  }

  void _addUrlField() {
    setState(() {
      _imageUrlsControllers.add(TextEditingController());
    });
  }

  void _removeUrlField(int index) {
    setState(() {
      _imageUrlsControllers[index].dispose();
      _imageUrlsControllers.removeAt(index);
    });
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
                      controller: _nameController,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBAC9CC)), borderRadius: BorderRadius.circular(4)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: ['agroturismo', 'recreacional', 'metalmecanico', 'otro'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdminFormField(
                      label: 'DESCRIPCIÓN DEL PAQUETE',
                      hint: 'Detalle exhaustivo...',
                      controller: _descriptionController,
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
                          Switch(
                            value: _isAvailable,
                            activeColor: const Color(0xFF006C49),
                            onChanged: (val) => setState(() => _isAvailable = val),
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
                  controller: _capacityController,
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
                      controller: _priceController,
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
                    ..._imageUrlsControllers.asMap().entries.map((entry) {
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
                              onPressed: () => _removeUrlField(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addUrlField,
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
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _savePackage,
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save, color: Colors.white, size: 18),
                  label: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C49), padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}