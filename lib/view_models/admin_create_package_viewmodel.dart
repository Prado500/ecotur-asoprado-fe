import 'package:flutter/material.dart';
import '../services/catalog_service.dart';

/// ViewModel orchestrating the package creation form state for Admins.
/// Handles dynamic collections of text controllers and strict business validations.
class AdminCreatePackageViewModel extends ChangeNotifier {
  final CatalogService _catalogService;

  // Single-value Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  // Dynamic collection of image URL controllers
  final List<TextEditingController> imageUrlsControllers = [];

  String _selectedCategory = 'metalmecanico';
  bool _isAvailable = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  AdminCreatePackageViewModel(this._catalogService);

  String get selectedCategory => _selectedCategory;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Updates the category dropdown state.
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Updates the availability toggle switch state.
  void setAvailability(bool value) {
    _isAvailable = value;
    notifyListeners();
  }

  /// Appends a new empty text controller to the image URLs list dynamically.
  void addUrlField() {
    imageUrlsControllers.add(TextEditingController());
    notifyListeners();
  }

  /// Disposes and removes an image URL controller at the specified [index].
  void removeUrlField(int index) {
    imageUrlsControllers[index].dispose();
    imageUrlsControllers.removeAt(index);
    notifyListeners();
  }

  /// Orchestrates the data assembly and invokes the domain service creation contract.
  Future<void> savePackage() async {
    _setLoading(true);
    clearError();

    // Filter out empty URLs to maintain payload integrity
    List<String> urlsList = imageUrlsControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final packageData = {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": _selectedCategory,
      "base_price": double.tryParse(priceController.text) ?? 0.0,
      "max_capacity": int.tryParse(capacityController.text) ?? 1,
      "is_available": _isAvailable,
      "image_urls": urlsList,
    };

    final result = await _catalogService.createService(packageData);

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