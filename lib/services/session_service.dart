import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's global session state (App-Wide State).
/// It strictly handles token persistence, role decoding, and state broadcasting,
/// remaining completely agnostic to network operations.
class SessionService extends ChangeNotifier {
  static const String _tokenKey = 'jwt_token';

  String? _token;
  bool _isAuthenticated = false;
  String _userRole = 'tourist';

  /// Returns the current raw JWT token for HTTP requests
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;

  /// Establishes an active session in local storage and memory after a successful login.
  Future<void> establishSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    _token = token;
    _userRole = _getRoleFromToken(token);
    _isAuthenticated = true;
    notifyListeners(); // Broadcasts the login event globally
  }

  /// Destroys the current session and purges the token from the device.
  Future<void> destroySession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    _token = null;
    _isAuthenticated = false;
    _userRole = 'tourist';
    notifyListeners(); // Broadcasts the logout event globally
  }

  /// Verifies if a valid session token currently exists in local storage and is not expired.
  Future<bool> checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_tokenKey);

    if (storedToken != null && storedToken.isNotEmpty) {
      // Si el token está expirado, destruye la sesión y redirige al screen de login
      if (_isTokenExpired(storedToken)) {
        await destroySession();
        return false;
      }

      _token = storedToken;
      _userRole = _getRoleFromToken(storedToken);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    _isAuthenticated = false;
    return false;
  }

  /// Checks if the JWT token is expired based on its 'exp' claim.
  bool _isTokenExpired(String token) {
    try {
      final payloadData = _decodeJwtPayload(token);
      if (payloadData == null || !payloadData.containsKey('exp')) return false;

      final expSeconds = payloadData['exp'] as int;
      final expDate = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
      return DateTime.now().toUtc().isAfter(expDate);
    } catch (_) {
      return false;
    }
  }

  /// Decodes the JWT payload to extract claims safely.
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String decoded = utf8.decode(base64Url.decode(normalized));

      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Decodes the JWT payload to extract the user's role without external dependencies.
  String _getRoleFromToken(String token) {
    final payload = _decodeJwtPayload(token);
    return payload?['role'] ?? 'tourist';
  }
}