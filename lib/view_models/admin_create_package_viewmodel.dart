import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/catalog_service.dart';
import '../models/tourist_service_model.dart';

/// ViewModel orchestrating the package creation and edition form state.
/// Implements an "Eager Uploading" pattern: local files are immediately pushed
/// to the CDN staging environment, maintaining a unified List<String> of URLs.
class AdminCreatePackageViewModel extends ChangeNotifier {

  final CatalogService _catalogService;
  final TouristService? serviceToEdit;

  // Single-value Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  // Unified Image Management (Only URLs exist here, no XFiles in memory)
  final List<String> _selectedImagesUrls = [];
  final Map<String, String> _imageNamesMap = {};
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'metalmecanico';
  bool _isLoading = false;          // Controls the main Save/Update button
  bool _isUploadingImages = false;  // Controls the Eager Upload UI locks
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
      // Hydrate the baseline state with existing permanent CDN URLs
      _selectedImagesUrls.addAll(serviceToEdit!.imageUrls);
      for (var url in serviceToEdit!.imageUrls) {
        _imageNamesMap[url] = url.split('/').last;
      }
    }
  }

  List<String> get selectedImagesUrls => _selectedImagesUrls;
  Map<String, String> get imageNamesMap => _imageNamesMap;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isUploadingImages => _isUploadingImages;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  bool get isEditMode => serviceToEdit != null;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Eager Uploading Pattern: Invokes the native file picker and immediately
  /// dispatches the binary chunks to the backend's staging endpoint.
  Future<void> pickImages() async {
    // 1. Native Picker Invocation
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isEmpty) return;

    // 2. Fail-Fast UI Boundary Validation
    if (_selectedImagesUrls.length + images.length > 10) {
      _setError('No puedes tener más de 10 imágenes en total por paquete.');
      return;
    }

    // 3. UI Lock State Mutation
    _isUploadingImages = true;
    notifyListeners();

    try {
      // 4. Staging Delegation
      final List<String> temporalUrls = await _catalogService.uploadStagingImages(images);

      // 5. State Hydration
      _selectedImagesUrls.addAll(temporalUrls);

      for (int i = 0; i < temporalUrls.length; i++) {
        _imageNamesMap[temporalUrls[i]] = images[i].name;
      }

    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      // 6. UI Unlock State Mutation
      _isUploadingImages = false;
      notifyListeners();
    }
  }

  /// Removes a URL from the payload queue (Does not trigger immediate backend deletion).
  void removeImage(int index) {
    if (_isUploadingImages) return; // Prevent mutation during I/O locks
    String removedUrl = _selectedImagesUrls.removeAt(index);
    _imageNamesMap.remove(removedUrl);
    notifyListeners();
  }

  /// Reorders the declarative array based on user Drag & Drop interaction.
  void reorderImages(int oldIndex, int newIndex) {
    if (_isUploadingImages) return; // Prevent mutation during I/O locks
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String item = _selectedImagesUrls.removeAt(oldIndex);
    _selectedImagesUrls.insert(newIndex, item);
    notifyListeners();
  }

  /// Extracts scalar form data and arrays into a unified pure JSON Map.
  Map<String, dynamic> _buildJsonPayload() {
    final rawPriceString = priceController.text.replaceAll('.', '').trim();
    return {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": _selectedCategory,
      "base_price": double.tryParse(rawPriceString) ?? 0.0,
      "max_capacity": int.tryParse(capacityController.text.trim()) ?? 1,
      "image_urls": _selectedImagesUrls,
    };
  }

  /// Executes the creation workflow dispatching a pure JSON payload.
  Future<void> savePackage() async {
    if (_selectedImagesUrls.isEmpty) {
      _setError('Debes seleccionar al menos una imagen (la portada) para el paquete.');
      return;
    }

    _setLoading(true);
    clearError();

    final payload = _buildJsonPayload();
    final result = await _catalogService.createService(payload);

    _handleResponse(result);
  }

  /// Executes the update workflow dispatching a pure JSON payload.
  Future<void> updatePackage() async {
    if (serviceToEdit == null) return;
    if (_selectedImagesUrls.isEmpty) {
      _setError('Debes seleccionar al menos una imagen (la portada) para el paquete.');
      return;
    }

    _setLoading(true);
    clearError();

    final payload = _buildJsonPayload();
    // Injects the implicitly defined active status mapping back to the API validation schema
    payload["is_available"] = serviceToEdit!.isAvailable;

    final result = await _catalogService.updateService(serviceToEdit!.id, payload);

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