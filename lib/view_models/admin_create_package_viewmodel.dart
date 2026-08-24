import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/catalog_service.dart';
import '../models/tourist_service_model.dart';

/// ViewModel orchestrating the package creation and edition form state.
/// Operates in a Bimodal fashion: creates a new package (multipart) if [serviceToEdit] is null,
/// or updates the existing entity (JSON) if provided.
class AdminCreatePackageViewModel extends ChangeNotifier {

  final CatalogService _catalogService;
  final TouristService? serviceToEdit;

  // Single-value Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  // Multipart File Management
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'metalmecanico';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  /// Injects dependencies and pre-fills form controllers if operating in Edit Mode.
  AdminCreatePackageViewModel(this._catalogService, {this.serviceToEdit}) {
    if (serviceToEdit != null) {
      nameController.text = serviceToEdit!.name;
      descriptionController.text = serviceToEdit!.description;
      priceController.text = serviceToEdit!.basePrice.toStringAsFixed(0);
      capacityController.text = serviceToEdit!.maxCapacity.toString();
      _selectedCategory = serviceToEdit!.category.toLowerCase();
      // Nota: En modo edición las imágenes no se precargan aquí como XFiles porque ya viven en el CDN.
    }
  }

  List<XFile> get selectedImages => _selectedImages;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  bool get isEditMode => serviceToEdit != null;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Invokes the native file picker to select multiple images.
  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      // Validar que no superen el límite de 10 imágenes del backend
      if (_selectedImages.length + images.length > 10) {
        _setError('No puedes seleccionar más de 10 imágenes en total.');
        return;
      }
      _selectedImages.addAll(images);
      notifyListeners();
    }
  }

  /// Removes an image from the pending upload queue.
  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  /// Reorders the list based on user Drag & Drop interaction.
  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final XFile item = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, item);
    notifyListeners();
  }

  /// Extracts scalar form data into a Map<String, String> for multipart extraction (POST).
  Map<String, String> _buildMultipartFields() {
    final rawPriceString = priceController.text.replaceAll('.', '').trim();
    return {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": _selectedCategory,
      "base_price": rawPriceString.isEmpty ? "0" : rawPriceString,
      "max_capacity": capacityController.text.trim(),
      "is_available": "false",
    };
  }

  /// Executes the creation workflow (POST with Multipart).
  Future<void> savePackage() async {
    if (_selectedImages.isEmpty) {
      _setError('Debes seleccionar al menos una imagen (la portada) para el paquete.');
      return;
    }

    _setLoading(true);
    clearError();

    final fields = _buildMultipartFields();
    final result = await _catalogService.createServiceWithImages(fields, _selectedImages);

    _handleResponse(result);
  }

  /// Executes the update workflow (PUT).
  Future<void> updatePackage() async {
    if (serviceToEdit == null) return;

    _setLoading(true);
    clearError();

    // La actualización usa JSON estándar.
    // Para actualizar imágenes se requiere lógica diferente (ej. borrar/añadir desde otro endpoint).
    final rawPriceString = priceController.text.replaceAll('.', '').trim();
    final packageData = {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": _selectedCategory,
      "base_price": double.tryParse(rawPriceString) ?? 0.0,
      "max_capacity": int.tryParse(capacityController.text.trim()) ?? 1,
    };

    final result = await _catalogService.updateService(serviceToEdit!.id, packageData);
    _handleResponse(result);
  }

  void _handleResponse(Map<String, dynamic> result) {
    _setLoading(false);
    if (result['success']) {
      _isSuccess = true;
      notifyListeners();
    } else {
      _setError(result['message']);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    capacityController.dispose();
    super.dispose();
  }
}