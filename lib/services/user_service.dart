import 'package:flutter/foundation.dart';
import '../abstractions/api_client.dart';
import '../models/user_model.dart';

/// Stateless Domain Service handling User and Tourist-related networking operations.
///
/// It acts as the networking intermediary between the ViewModels and the [ApiClient],
/// strictly mapping DTOs and handling raw HTTP responses.
class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Registers a new tourist by dispatching the payload to the backend.
  ///
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
  ///
  /// Consumes the protected GET `/usuarios/mi-perfil` endpoint.
  Future<Map<String, dynamic>> fetchMyProfile() async {
    try {
      return await _apiClient.get('/usuarios/mi-perfil');
    } catch (e) {
      debugPrint('CRITICAL ERROR IN TOURIST SERVICE (fetchMyProfile): $e');
      return {'success': false, 'message': 'Unexpected network error loading profile.'};
    }
  }

  /// Retrieves the complete directory of active and inactive users.
  ///
  /// Consumes the protected GET `/usuarios/` endpoint. The backend automatically
  /// enforces hierarchical visibility rules (e.g., obscuring superadmins).
  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await _apiClient.get('/usuarios/');
      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(response['message']);
    } catch (e) {
      debugPrint('Error in TouristService (fetchUsers): $e');
      throw Exception('Failed to load the user directory.');
    }
  }

  /// Retrieves the collection of logically deleted users.
  ///
  /// Consumes the administrative GET `/usuarios/admin/eliminados` endpoint
  /// to populate the recycle bin Kanban column.
  Future<List<UserModel>> fetchDeletedUsers() async {
    try {
      final response = await _apiClient.get('/usuarios/admin/eliminados');
      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(response['message']);
    } catch (e) {
      debugPrint('Error in TouristService (fetchDeletedUsers): $e');
      throw Exception('Failed to load deleted users.');
    }
  }

  /// Dispatches a PATCH request to mutate a user's profile or status.
  ///
  /// Utilizes the [cedula] as the primary identifier.
  Future<Map<String, dynamic>> updateUser(String cedula, Map<String, dynamic> updateData) async {
    return await _apiClient.patch('/usuarios/$cedula', body: updateData);
  }

  /// Soft-deletes a user account, migrating it to the recycle bin.
  Future<Map<String, dynamic>> deleteUser(String cedula) async {
    return await _apiClient.delete('/usuarios/$cedula');
  }

  /// Recovers a soft-deleted user account by its [cedula].
  ///
  /// Restores the entity to an inactive state pending administrative review.
  Future<Map<String, dynamic>> recoverUser(String cedula) async {
    return await _apiClient.patch('/usuarios/$cedula/recuperar');
  }

  /// Provisions a new administrative user bypassing the public registration pipeline.
  ///
  /// Expects a structured [userData] dictionary complying with the backend's
  /// `UserCreateByAdmin` Pydantic schema constraints.
  Future<Map<String, dynamic>> createAdminUser(Map<String, dynamic> userData) async {
    return await _apiClient.post('/usuarios/admin', userData);
  }
}