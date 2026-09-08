import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../models/tourist_service_model.dart';

/// ViewModel responsible for orchestrating the state of the Catalog screen.
/// It consumes the [CatalogService] domain layer and exposes fine-grained UI states.
class CatalogViewModel extends ChangeNotifier {
  final CatalogService _catalogService;

  List<TouristService> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  CatalogViewModel(this._catalogService);

  /// Exposes the list of retrieved tourist services.
  List<TouristService> get services => _services;

  /// Exposes the current loading state to toggle spinners in the view.
  bool get isLoading => _isLoading;

  /// Exposes the error message if the domain operation fails.
  String? get errorMessage => _errorMessage;

  /// Triggers the background data fetching operation through the domain service.
  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // <-- Dispatches update event to the view layer

    try {
      _services = await _catalogService.fetchServices();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners(); // <-- Notifies loading completion and data injection
    }
  }
}