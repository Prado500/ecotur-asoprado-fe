import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class AuthService {
  static const String _tokenKey = 'jwt_token';

  /// Obtiene la URL base inyectada dinámicamente según el entorno.
  String get baseUrl {
    String url = dotenv.env['API_URL'] ?? 'http://localhost:8000';

    if (!kIsWeb && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }

    return url;
  }

  /// Autentica al usuario contra el backend y almacena el JWT localmente.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);

        return {
          'success': true,
          'token': token,
          'role': _getRoleFromToken(token),
        };
      } else {
        return _handleApiError(response, 'iniciar sesión');
      }
    } catch (e) {
      debugPrint('CRASH DE RED EN FRONTEND (Login): $e');
      return {'success': false, 'message': 'No se pudo conectar con el servidor.'};
    }
  }

  /// Registra un nuevo usuario en el sistema.
  Future<Map<String, dynamic>> register(
      String email, String password, String firstName, String lastName, String phone, bool dataConsent) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'password': password,
          'data_consent': dataConsent,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        return _handleApiError(response, 'registrar');
      }
    } catch (e) {
      debugPrint('CRASH DE RED EN FRONTEND (Registro): $e');
      return {'success': false, 'message': 'No se pudo conectar con el servidor.'};
    }
  }

  /// Verifica si existe una sesión activa basada en la presencia del token.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  /// Cierra la sesión eliminando el token almacenado.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Centraliza el procesamiento seguro de errores provenientes de Pydantic/FastAPI.
  Map<String, dynamic> _handleApiError(http.Response response, String action) {
    debugPrint("ERROR FASTAPI (${response.statusCode}): ${response.body}");
    try {
      final data = json.decode(utf8.decode(response.bodyBytes));
      String errorMessage = 'Error al $action (Código: ${response.statusCode})';

      if (data['detail'] != null) {
        if (data['detail'] is List && data['detail'].isNotEmpty) {
          final firstError = data['detail'][0] as Map<String, dynamic>;
          final locList = firstError['loc'] as List<dynamic>?;
          final msg = firstError['msg']?.toString() ?? 'Error de validación';

          String fieldName = 'Campo';
          if (locList != null && locList.isNotEmpty) {
            fieldName = locList.last.toString();
          }
          errorMessage = "$fieldName: $msg";
        } else if (data['detail'] is String) {
          errorMessage = data['detail'];
        }
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('Error al decodificar JSON de error: $e');
      return {'success': false, 'message': 'El servidor devolvió un error (Código: ${response.statusCode})'};
    }
  }

  /// Decodifica el JWT de forma ligera para extraer el rol del usuario.
  String _getRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 'turista';

      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String decoded = utf8.decode(base64Url.decode(normalized));

      final data = json.decode(decoded);
      return data['role'] ?? 'turista';
    } catch (e) {
      return 'turista';
    }
  }
}