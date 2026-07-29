import 'package:flutter/foundation.dart';
import '../abstractions/api_client.dart';

/// Stateless Domain Service handling Tourist-related operations.
/// It acts as the intermediary between the ViewModels and the [ApiClient].
class TouristService {
  final ApiClient _apiClient = ApiClient();

  /// Registers a new tourist by dispatching the payload to the backend.
  /// Returns a standardized map containing the operation's success status and message.
  Future<Map<String, dynamic>> registerTourist({
    required String cedula,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required bool dataConsent,
  }) async {
    try {
      return await _apiClient.post('/usuarios/registro', {
        'cedula': cedula,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'data_consent': dataConsent,
      });
    } catch (e) {
      debugPrint('CRITICAL ERROR IN TOURIST SERVICE (registerTourist): $e');
      return {'success': false, 'message': 'Unexpected network error during registration.'};
    }
  }


  /// Fetches the generic profile data of the currently authenticated user.
  /// Consumes the protected GET /usuarios/mi-perfil endpoint.
  Future<Map<String, dynamic>> fetchMyProfile() async {
    try {
      return await _apiClient.get('/usuarios/mi-perfil');
    } catch (e) {
      debugPrint('CRITICAL ERROR IN TOURIST SERVICE (fetchMyProfile): $e');
      return {'success': false, 'message': 'Error de red inesperado al cargar el perfil.'};
    }
  }

}