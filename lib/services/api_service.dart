import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../models/tourist_service_model.dart';

class ApiService {

  /// Obtiene la URL base inyectada dinámicamente según el entorno.
  String get baseUrl {
    const String pipelineUrl = String.fromEnvironment('API_URL');


    if (pipelineUrl.isNotEmpty) {
      return pipelineUrl;
    }

    String url = dotenv.env['API_URL'] ?? 'http://localhost:8000';

    if (!kIsWeb && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }

    return url;
  }

  /// Recupera el catálogo completo de servicios turísticos.
  Future<List<TouristService>> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/servicios/'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((service) => TouristService.fromJson(service)).toList();
      } else {
        String errorMessage = 'Error al cargar el catálogo (Código: ${response.statusCode})';
        try {
          final data = json.decode(utf8.decode(response.bodyBytes));
          if (data['detail'] != null) {
            errorMessage = data['detail'].toString();
          }
        } catch (_) {
          // Fallback silencioso si la respuesta no es un JSON procesable
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('CRASH EN API SERVICE (fetchServices): $e');
      throw Exception('No pudimos conectar con el servidor. Verifica tu conexión.');
    }
  }

  /// Envía la petición para crear un nuevo paquete turístico (Requiere autenticación).
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('$baseUrl/servicios/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(serviceData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        debugPrint("ERROR FASTAPI (422): ${response.body}");
        try {
          final data = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = 'Error al crear (Código: ${response.statusCode})';

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
          return {'success': false, 'message': 'El servidor devolvió un error (Código: ${response.statusCode})'};
        }
      }
    } catch (e) {
      debugPrint('CRASH EN API SERVICE (createService): $e');
      return {'success': false, 'message': 'Error de conexión con el servidor.'};
    }
  }
}