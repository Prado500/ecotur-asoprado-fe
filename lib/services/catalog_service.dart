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
}