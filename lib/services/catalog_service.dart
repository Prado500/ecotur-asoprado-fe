import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import '../abstractions/api_client.dart';
import '../models/tourist_service_model.dart';

/// Domain Service responsible for tourist package operations.
/// Interacts directly with the [ApiClient] abstraction enforcing pure JSON contracts for entity mutations.
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

  /// Dispatches the pure JSON payload to create a new tourist package.
  /// Enforces the new asynchronous staging architecture.
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    return await _apiClient.post('/servicios/', serviceData);
  }

  /// Uploads binary files to the ephemeral Azure staging container.
  /// Returns a list of temporal CDN URLs to be injected into the final JSON payload.
  Future<List<String>> uploadStagingImages(List<XFile> images) async {
    try {
      // Delegating to postMultipart with empty fields, as the backend only expects the binary chunks
      final response = await _apiClient.postMultipart('/servicios/upload-images/', {}, images);

      if (response['success']) {
        final List<dynamic> urls = response['data']['image_urls'] ?? [];
        return urls.map((url) => url.toString()).toList();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      debugPrint('Error in CatalogService (uploadStagingImages): $e');
      throw Exception('Fallo al subir imágenes al entorno temporal (Staging).');
    }
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
    return await _apiClient.patch('/servicios/$serviceId/activar');
  }

  /// Triggers a state mutation transitioning a package to Inactive.
  Future<Map<String, dynamic>> deactivateService(int serviceId) async {
    return await _apiClient.patch('/servicios/$serviceId/desactivar');
  }

  /// Recovers a soft-deleted package back to the Inactive queue.
  Future<Map<String, dynamic>> recoverService(int serviceId) async {
    return await _apiClient.patch('/servicios/$serviceId/recuperar');
  }

  /// Soft deletes a package, sending it to the recycling bin.
  Future<Map<String, dynamic>> softDeleteService(int serviceId) async {
    return await _apiClient.delete('/servicios/$serviceId');
  }

  /// Dispatches the JSON payload to update an existing tourist package.
  Future<Map<String, dynamic>> updateService(int serviceId, Map<String, dynamic> serviceData) async {
    return await _apiClient.put('/servicios/$serviceId', serviceData);
  }
}