import 'package:flutter/foundation.dart';
import '../abstractions/api_client.dart';

/// Stateless Domain Service handling Authentication networking.
/// It strictly executes transactional backend requests, delegating global state
/// management to the [SessionService].
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Executes the login network request against the backend infrastructure.
  /// Returns the raw API response mapped to a unified dictionary contract.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _apiClient.post('/usuarios/login', {
        'email': email.trim(),
        'password': password,
      });
    } catch (e) {
      debugPrint('CRITICAL ERROR IN AUTH SERVICE (login): $e');
      return {'success': false, 'message': 'Unexpected network error during login.'};
    }
  }

  /// Executes the email verification network request using the provided JWT token.
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      return await _apiClient.get('/usuarios/verificar-email?token=$token');
    } catch (e) {
      debugPrint('CRITICAL ERROR IN AUTH SERVICE (verifyEmail): $e');
      return {'success': false, 'message': 'Unexpected network error during verification.'};
    }
  }

}