import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../services/user_service.dart' as user_api;
import '../models/tourist_service_model.dart';
import '../models/user_model.dart';

/// Defines specific transition directives for package state mutations.
enum PackageAction { activate, deactivate, softDelete, recover }

/// Defines specific transition directives for user account state mutations.
enum UserAction { activate, deactivate, softDelete, recover }

/// Manages the state and parallel data hydration for the Kanban interface.
///
/// Operates contextually based on the requested entity type, seamlessly shifting
/// entities across memory arrays to prevent expensive layout repaints.
class AdminKanbanViewModel extends ChangeNotifier {
  final CatalogService _catalogService;
  final user_api.UserService _touristService;
  final String entityType;

  List<TouristService> _activePackages = [];
  List<TouristService> _inactivePackages = [];
  List<TouristService> _deletedPackages = [];

  List<UserModel> _activeUsers = [];
  List<UserModel> _inactiveUsers = [];
  List<UserModel> _deletedUsers = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  AdminKanbanViewModel(this._catalogService, this._touristService, this.entityType);

  List<TouristService> get activePackages => _activePackages;
  List<TouristService> get inactivePackages => _inactivePackages;
  List<TouristService> get deletedPackages => _deletedPackages;

  List<UserModel> get activeUsers => _activeUsers;
  List<UserModel> get inactiveUsers => _inactiveUsers;
  List<UserModel> get deletedUsers => _deletedUsers;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Hydrates the Kanban columns concurrently based on the target entity context.
  Future<void> loadKanbanBoard() async {
    _setLoading(true);
    _clearMessages();

    try {
      if (entityType == 'paquetes') {
        final results = await Future.wait([
          _catalogService.fetchServices(),
          _catalogService.fetchInactiveServices(),
          _catalogService.fetchDeletedServices(),
        ]);
        _activePackages = results[0];
        _inactivePackages = results[1];
        _deletedPackages = results[2];
      } else if (entityType == 'usuarios') {
        final results = await Future.wait([
          _touristService.fetchUsers(),
          _touristService.fetchDeletedUsers(),
        ]);

        final allLiveUsers = results[0];
        _activeUsers = allLiveUsers.where((u) => u.isActive).toList();
        _inactiveUsers = allLiveUsers.where((u) => !u.isActive).toList();
        _deletedUsers = results[1];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Dispatches state mutation commands for Package entities and handles optimistic shifting.
  Future<void> mutatePackageState(TouristService service, PackageAction action) async {
    _setLoading(true);
    _clearMessages();

    final int targetId = service.id;
    if (targetId == 0) {
      _errorMessage = 'Error de integridad: ID inválido.';
      _setLoading(false);
      return;
    }

    Map<String, dynamic> result;
    try {
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

      if (result['success']) {
        _successMessage = result['message'];
        loadKanbanBoard(); // Full rehydration ensures DB synchronicity
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Fallo de red al intentar mutar el estado del paquete.';
    } finally {
      _setLoading(false);
    }
  }

  /// Dispatches state mutation commands for User entities.
  Future<void> mutateUserState(UserModel user, UserAction action) async {
    _setLoading(true);
    _clearMessages();

    Map<String, dynamic> result;
    try {
      switch (action) {
        case UserAction.activate:
          result = await _touristService.updateUser(user.cedula, {'is_active': true});
          break;
        case UserAction.deactivate:
          result = await _touristService.updateUser(user.cedula, {'is_active': false});
          break;
        case UserAction.softDelete:
          result = await _touristService.deleteUser(user.cedula);
          break;
        case UserAction.recover:
          result = await _touristService.recoverUser(user.cedula);
          break;
      }

      if (result['success']) {
        _successMessage = result['message'] ?? 'Operación completada.';
        loadKanbanBoard(); // Full rehydration ensures DB synchronicity
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Fallo de red al intentar mutar el estado del usuario.';
    } finally {
      _setLoading(false);
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