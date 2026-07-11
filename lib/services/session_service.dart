import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's global session state (App-Wide State).
/// It strictly handles token persistence, role decoding, and state broadcasting,
/// remaining completely agnostic to network operations.
class SessionService extends ChangeNotifier {
  static const String _tokenKey = 'jwt_token';

  bool _isAuthenticated = false;
  String _userRole = 'tourist';

  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;

  /// Establishes an active session in local storage and memory after a successful login.
  Future<void> establishSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    _userRole = _getRoleFromToken(token);
    _isAuthenticated = true;
    notifyListeners(); // Broadcasts the login event globally
  }

  /// Destroys the current session and purges the token from the device.
  Future<void> destroySession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    _isAuthenticated = false;
    _userRole = 'tourist';
    notifyListeners(); // Broadcasts the logout event globally
  }

  /// Verifies if a valid session token currently exists in local storage.
  Future<bool> checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_tokenKey)) {
      final token = prefs.getString(_tokenKey)!;
      _userRole = _getRoleFromToken(token);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Decodes the JWT payload to extract the user's role without external dependencies.
  String _getRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 'tourist';

      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String decoded = utf8.decode(base64Url.decode(normalized));

      final data = json.decode(decoded);
      return data['role'] ?? 'tourist';
    } catch (e) {
      return 'tourist';
    }
  }
}