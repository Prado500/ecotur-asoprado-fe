import 'package:flutter/foundation.dart';
import '../abstractions/api_client.dart';
import '../models/tourist_service_model.dart';

/// Domain Service responsible for tourist package operations.
/// Interacts directly with the [ApiClient] abstraction.
class CatalogService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches the list of all active and available tourist packages.
  Future<List<TouristService>> fetchServices() async {
    try {
      final response = await _apiClient.get('/servicios/');

      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => TouristService.fromJson(json)).toList();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      debugPrint('Error in CatalogService (fetchServices): $e');
      throw Exception('Failed to load catalog. Please check your connection.');
    }
  }

  /// Dispatches the payload to create a new tourist package.
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    return await _apiClient.post('/servicios/', serviceData);
  }

  /// Fetches the list of inactive packages (Por Activar).
  /// Requires Admin JWT session.
  Future<List<TouristService>> fetchInactiveServices() async {
    try {
      final response = await _apiClient.get('/servicios/admin/inactivos');
      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => TouristService.fromJson(json)).toList();
      }
      throw Exception(response['message']);
    } catch (e) {
      debugPrint('Error in CatalogService (fetchInactiveServices): $e');
      throw Exception('Error de red al cargar paquetes inactivos.');
    }
  }

  /// Fetches the list of soft-deleted packages (Eliminados).
  /// Requires Admin JWT session.
  Future<List<TouristService>> fetchDeletedServices() async {
    try {
      final response = await _apiClient.get('/servicios/admin/eliminados');
      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => TouristService.fromJson(json)).toList();
      }
      throw Exception(response['message']);
    } catch (e) {
      debugPrint('Error in CatalogService (fetchDeletedServices): $e');
      throw Exception('Error de red al cargar paquetes eliminados.');
    }
  }

  /// Triggers a state mutation transitioning a package to Active.
  Future<Map<String, dynamic>> activateService(int serviceId) async {
    // Coincide con: @router.patch("/{service_id}/activar")
    return await _apiClient.patch('/servicios/$serviceId/activar');
  }

  /// Triggers a state mutation transitioning a package to Inactive.
  Future<Map<String, dynamic>> deactivateService(int serviceId) async {
    // Coincide con: @router.patch("/{service_id}/desactivar")
    return await _apiClient.patch('/servicios/$serviceId/desactivar');
  }

  /// Recovers a soft-deleted package back to the Inactive queue.
  Future<Map<String, dynamic>> recoverService(int serviceId) async {
    // Coincide con: @router.patch("/{service_id}/recuperar")
    return await _apiClient.patch('/servicios/$serviceId/recuperar');
  }

  /// Soft deletes a package, sending it to the recycling bin.
  Future<Map<String, dynamic>> softDeleteService(int serviceId) async {
    // Coincide con: @router.delete("/{service_id}")
    return await _apiClient.delete('/servicios/$serviceId');
  }


}

