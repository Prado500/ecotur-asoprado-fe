import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminCreatePackageScreen extends StatefulWidget {
  const AdminCreatePackageScreen({super.key});

  @override
  _AdminCreatePackageScreenState createState() => _AdminCreatePackageScreenState();

}

class _AdminCreatePackageScreenState extends State<AdminCreatePackageScreen> {
  // Llave maestra para validar todo el formulario de golpe
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();

  // Lista dinámica para guardar los controladores de las URLs de imágenes
  final List<TextEditingController> _imageUrlsControllers = [];

  String _selectedCategory = 'metalmecanico';
  bool _isAvailable = true;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    // Limpiamos la memoria de todos los renglones generados
    for (var controller in _imageUrlsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _savePackage() async {
    // Esto dispara TODAS las validaciones rojas en pantalla de golpe
    if (!_formKey.currentState!.validate()) {
      return; // Si algo falló, se detiene y no llama al backend
    }

    setState(() => _isLoading = true);

    List<String> urlsList = _imageUrlsControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final packageData = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "category": _selectedCategory, // OJO: Si aquí dice 'metalmecanico', FastAPI debe tener EXACTAMENTE esa opción.
      "base_price": double.tryParse(_priceController.text) ?? 0.0,
      "max_capacity": int.tryParse(_capacityController.text) ?? 1,
      "is_available": _isAvailable,
      "image_urls": urlsList,
    };

    // Ahora esperamos un Map en lugar de un bool
    final result = await _apiService.createService(packageData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Paquete creado exitosamente!'), backgroundColor: Color(0xFF006C49)),
      );
      Navigator.pop(context);
    } else {
      // AQUÍ ES LA MAGIA: Te mostrará el error exacto que escupió Pydantic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: const Color(0xFFBA1A1A)),
      );
    }
  }

  // --- LÓGICA PARA SPAWNEAR RENGLONES ---
  void _addUrlField() {
    setState(() {
      _imageUrlsControllers.add(TextEditingController());
    });
  }

  // --- LÓGICA PARA DESTRUIR RENGLONES ---
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
        child: Form( // <--- ENVOLVEMOS EN UN FORM
          key: _formKey,
        child: Column(
          children: [
            // --- SECCIÓN 1: DATOS MAESTROS ---
            _buildSectionCard(
              'DATOS MAESTROS DEL PAQUETE',
              const Color(0xFF006875),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NOMBRE DEL PAQUETE'),
                  _buildTextField(controller: _nameController,
                      hint: 'Ej. Ruta de la Cascada',
                    validator: (value) {
                      if (value == null || value.trim().length < 4) {
                        return 'El nombre debe ser más descriptivo (mín. 4 letras)';
                      }
                      return null; // Null significa que está todo OK
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildLabel('CATEGORÍA'),
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
                  _buildLabel('DESCRIPCIÓN DEL PAQUETE'),
                  _buildTextField(controller: _descriptionController, hint: 'Detalle exhaustivo...', maxLines: 4,
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

            // --- SECCIÓN 2: CAPACIDAD ---
            _buildSectionCard(
              'PARÁMETROS DE CAPACIDAD Y SERVICIO',
              const Color(0xFF6834D1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CAPACIDAD MÁX.'),
                  _buildTextField(controller: _capacityController, hint: 'Ej. 15', isNumeric: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requerido';
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Debe ser un número entero mayor a 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECCIÓN 3: MULTIMEDIA DINÁMICA ---
            _buildSectionCard(
              'FINANZAS Y RECURSOS MULTIMEDIA',
              const Color(0xFF006C49),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('PRECIO BASE (COP)'),
                  _buildTextField(controller: _priceController, hint: '\$ 0.00', isNumeric: true,validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Introduce un precio válido';
                    }
                    return null;
                  },
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('ENLACES DE IMÁGENES PÚBLICAS'),

                  // Iterador para renderizar los renglones que el usuario va pidiendo
                  ..._imageUrlsControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    TextEditingController controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTextField(controller: controller, hint: 'https://ejemplo.com/foto.jpg'),
                          ),
                          const SizedBox(width: 8),
                          // Botón para borrar este renglón
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
                            onPressed: () => _removeUrlField(index),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Botón Spawn
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
            const SizedBox(height: 120), // Margen inferior para que no lo tape el BottomSheet
          ],
        ),
      ),
      ),

      // --- BARRA INFERIOR FIJA DE GUARDAR ---
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

  // Helpers de UI
  Widget _buildSectionCard(String title, Color dotColor, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: dotColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFE2E8F0)),
          content,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF3B494C), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumeric = false,
    int maxLines = 1,
    String? Function(String?)? validator, // ¡Aceptamos funciones de validación!
  }) {
    return TextFormField( // Cambiamos TextField por TextFormField
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: validator, // Le pasamos la regla
      autovalidateMode: AutovalidateMode.onUserInteraction, // Valida mientras el usuario escribe
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBAC9CC)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBAC9CC)), borderRadius: BorderRadius.circular(4)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF006875)), borderRadius: BorderRadius.circular(4)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBA1A1A)), borderRadius: BorderRadius.circular(4)),
        focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBA1A1A)), borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}