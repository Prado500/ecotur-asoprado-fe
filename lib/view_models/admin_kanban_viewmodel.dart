import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../models/tourist_service_model.dart';

/// Defines the operational targets for state mutations in the Kanban board.
enum PackageAction { activate, deactivate, softDelete, recover }

/// ViewModel orchestrating the Kanban Board state logic.
/// Manages parallel data fetching and seamless memory array shifting to prevent
/// expensive full-page UI repaints.
class AdminKanbanViewModel extends ChangeNotifier {
  final CatalogService _catalogService;

  List<TouristService> _activePackages = [];
  List<TouristService> _inactivePackages = [];
  List<TouristService> _deletedPackages = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  /// Injects the domain service dependency.
  AdminKanbanViewModel(this._catalogService);

  List<TouristService> get activePackages => _activePackages;
  List<TouristService> get inactivePackages => _inactivePackages;
  List<TouristService> get deletedPackages => _deletedPackages;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Fetches all 3 column data arrays concurrently using Future.wait.
  /// This drastically reduces networking wait times.
  Future<void> loadKanbanBoard() async {
    _setLoading(true);
    _clearMessages();

    try {
      final results = await Future.wait([
        _catalogService.fetchServices(),
        _catalogService.fetchInactiveServices(),
        _catalogService.fetchDeletedServices(),
      ]);

      _activePackages = results[0];
      _inactivePackages = results[1];
      _deletedPackages = results[2];
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Dispatches the state mutation command to the backend and handles
  /// the optimistic shifting of the entity within memory arrays upon success.
  ///
  /// Args:
  ///   service (TouristService): The entity object to be mutated.
  ///   action (PackageAction): The specific operation to execute against the backend.
  Future<void> mutatePackageState(TouristService service, PackageAction action) async {
    _setLoading(true);
    _clearMessages();

    // 1. Safety Check: Ensure the entity possesses a valid relational database ID.
    final int targetId = service.id;
    if (targetId == 0) {
      _errorMessage = 'Error de integridad: El paquete seleccionado carece de un ID válido.';
      _setLoading(false);
      return;
    }

    Map<String, dynamic> result;

    try {
      // 2. Transactional Mapping: Route the action to the exact HTTP verb and endpoint.
      switch (action) {
        case PackageAction.activate:
          result = await _catalogService.activateService(targetId);
          break;
        case PackageAction.deactivate:
          result = await _catalogService.deactivateService(targetId);
          break;
        case PackageAction.softDelete:
          result = await _catalogService.softDeleteService(targetId);
          break;
        case PackageAction.recover:
          result = await _catalogService.recoverService(targetId);
          break;
      }

      // 3. Evaluate the unified API response contract.
      if (result['success']) {
        _successMessage = result['message'];

        // 4. RAM Memory shifting (Optimistic update pattern)
        _shiftEntityInMemory(service, action);
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Fallo de red al intentar mutar el estado del paquete.';
    } finally {
      _setLoading(false);
    }
  }

  /// Shifts the target entity across local arrays to reflect its new state
  /// instantly without requiring a full backend reload.
  void _shiftEntityInMemory(TouristService service, PackageAction action) {
    switch (action) {
      case PackageAction.activate:
        _inactivePackages.remove(service);
        _activePackages.add(service);
        break;
      case PackageAction.deactivate:
        _activePackages.remove(service);
        _inactivePackages.add(service);
        break;
      case PackageAction.softDelete:
        _activePackages.remove(service);
        _inactivePackages.remove(service);
        _deletedPackages.add(service);
        break;
      case PackageAction.recover:
        _deletedPackages.remove(service);
        _inactivePackages.add(service); // Enforced business rule: Recovers to inactive
        break;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Explicitly clears UI broadcast messages to prevent SnackBar looping.
  void consumeMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}