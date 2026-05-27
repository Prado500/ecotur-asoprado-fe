import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {


  String get baseUrl {
   
    String url = dotenv.env['API_URL'] ?? 'http://localhost:8000';


    if (!kIsWeb && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    
    return url;
  }

  static const String _tokenKey = 'jwt_token';

  // --- 1. LOGIN ---
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

        // Guardamos el token en el dispositivo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);

        // Extraemos la información útil (como el rol)
        return {
          'success': true,
          'token': token,
          'role': _getRoleFromToken(token),
        };
      } else {
        // --- DEFENSA EN PROFUNDIDAD: Manejo seguro de errores (422, 401, 404) ---
        print(" ERROR FASTAPI LOGIN (${response.statusCode}): ${response.body}");

        try {
          final data = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = 'Error al iniciar sesión (Código: ${response.statusCode})';

          if (data['detail'] != null) {
            if (data['detail'] is List && data['detail'].isNotEmpty) {
              // Manejo seguro de errores de validación de Pydantic (Listas)
              final firstError = data['detail'][0] as Map<String, dynamic>;
              final locList = firstError['loc'] as List<dynamic>?;
              final msg = firstError['msg']?.toString() ?? 'Error de validación';

              // Extraemos el nombre del campo de forma segura
              String fieldName = 'Campo';
              if (locList != null && locList.isNotEmpty) {
                fieldName = locList.last.toString();
              }

              errorMessage = "$fieldName: $msg";
            } else if (data['detail'] is String) {
              // Manejo de errores directos de FastAPI (ej: HTTPException detail="Credenciales incorrectas")
              errorMessage = data['detail'];
            }
          }
          return {'success': false, 'message': errorMessage};
        } catch (e) {
          print(' Error al decodificar JSON de error en login: $e');
          return {'success': false, 'message': 'El servidor devolvió un error (Código: ${response.statusCode})'};
        }
      }
    } catch (e) {
      // Capturamos caídas de red si el servidor de FastAPI está apagado
      print(' CRASH DE RED EN FRONTEND (Login): $e');
      return {'success': false, 'message': 'No se pudo conectar con el servidor.'};
    }
  }


  // --- 2. REGISTRO ---
  Future<Map<String, dynamic>> register(
      String email, String password, String firstName, String lastName, String phone, bool dataConsent) async {

    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/registro'), // Ajusta si tu ruta es /usuarios/registro
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'first_name': firstName, // Coincide con Pydantic
        'last_name': lastName,   // Coincide con Pydantic
        'phone': phone,          // Nuevo campo
        'password': password,
        'data_consent': dataConsent, // Nuevo campo
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        print(" ERROR FASTAPI (422): ${response.body}");

        try {
          final data = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = 'Error al registrar (Código: ${response.statusCode})';

          if (data['detail'] != null) {
            if (data['detail'] is List && data['detail'].isNotEmpty) {
              // Forma segura de leer la lista en Dart
              final firstError = data['detail'][0] as Map<String, dynamic>;
              final locList = firstError['loc'] as List<dynamic>?;
              final msg = firstError['msg']?.toString() ?? 'Error de validación';

              // Extraemos el nombre del campo de forma segura
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
          print(' Error al decodificar JSON de error: $e');
          return {'success': false, 'message': 'El servidor devolvió un error (Código: ${response.statusCode})'};
        }
      }

    }
  }

  // --- 3. UTILIDADES ---

  // Saber si hay un usuario conectado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Truco Ninja: Decodificar JWT en Dart sin librerías pesadas
  String _getRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 'turista'; // Fallback

      String payload = parts[1];
      // Restaurar el padding de base64 si es necesario
      String normalized = base64Url.normalize(payload);
      String decoded = utf8.decode(base64Url.decode(normalized));

      final data = json.decode(decoded);
      return data['role'] ?? 'turista';
    } catch (e) {
      return 'turista';
    }
  }
}