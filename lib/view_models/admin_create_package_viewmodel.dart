import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../models/tourist_service_model.dart';

/// ViewModel orchestrating the package creation and edition form state.
/// Operates in a Bimodal fashion: creates a new package if [serviceToEdit] is null,
/// or updates the existing entity if provided.
class AdminCreatePackageViewModel extends ChangeNotifier {
  final CatalogService _catalogService;
  final TouristService? serviceToEdit;

  // Single-value Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final List<TextEditingController> imageUrlsControllers = [];

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

      for (var url in serviceToEdit!.imageUrls) {
        imageUrlsControllers.add(TextEditingController(text: url));
      }
    }
  }

  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Computed property to determine the current operational mode of the view.
  bool get isEditMode => serviceToEdit != null;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addUrlField() {
    imageUrlsControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeUrlField(int index) {
    imageUrlsControllers[index].dispose();
    imageUrlsControllers.removeAt(index);
    notifyListeners();
  }

  /// Extracts form data into a sanitized JSON map complying with backend Pydantic schemas.
  /// Used specifically for CREATING new packages.
  Map<String, dynamic> _buildCreationPayload() {
    List<String> urlsList = imageUrlsControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final rawPriceString = priceController.text.replaceAll('.', '').trim();

    return {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": _selectedCategory,
      "base_price": double.tryParse(rawPriceString) ?? 0.0,
      "max_capacity": int.tryParse(capacityController.text.trim()) ?? 1,
      "is_available": false, // <-- Nace inactivo obligatoriamente. El Kanban dictará su destino.
      "image_urls": urlsList,
    };
  }

  /// Extracts form data into a sanitized JSON map complying with backend Pydantic schemas.
  /// Used specifically for UPDATING existing packages.
  Map<String, dynamic> _buildUpdatePayload() {
    List<String> urlsList = imageUrlsControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final rawPriceString = priceController.text.replaceAll('.', '').trim();

    return {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": _selectedCategory,
      "base_price": double.tryParse(rawPriceString) ?? 0.0,
      "max_capacity": int.tryParse(capacityController.text.trim()) ?? 1,
      // Omitimos 'is_available' deliberadamente.
      // El backend (ServiceUpdate) lo interpretará como None y NO sobreescribirá el estado actual.
      "image_urls": urlsList,
    };
  }

  /// Executes the creation workflow (POST).
  Future<void> savePackage() async {
    _setLoading(true);
    clearError();

    final packageData = _buildCreationPayload();
    final result = await _catalogService.createService(packageData);

    _handleResponse(result);
  }

  /// Executes the update workflow (PUT).
  Future<void> updatePackage() async {
    if (serviceToEdit == null) return;

    _setLoading(true);
    clearError();

    final packageData = _buildUpdatePayload();
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
    for (var controller in imageUrlsControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}