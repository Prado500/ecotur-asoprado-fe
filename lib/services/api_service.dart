import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tourist_service_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {

  String get baseUrl {
    String url = dotenv.env['API_URL'] ?? 'http://localhost:8000';

    if (!kIsWeb && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    
    return url;
  }
  Future<List<TouristService>> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/servicios/'), // Asegúrate que este sea tu endpoint correcto
        headers: {
          'Accept': 'application/json',
          // Aquí en el futuro enviarás el token JWT en el header 'Authorization'
        },
      );

      if (response.statusCode == 200) {
        // Parseo seguro con UTF-8 para tildes
        List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((service) => TouristService.fromJson(service)).toList();
      } else {
        // --- MANEJO DE ERRORES DEL BACKEND (Ej: 422, 500) ---
        String errorMessage = 'Error al cargar el catálogo (Código: ${response.statusCode})';
        try {
          final data = json.decode(utf8.decode(response.bodyBytes));
          if (data['detail'] != null) {
            errorMessage = data['detail'].toString(); // Extraemos el error de FastAPI
          }
        } catch (_) {
          // Si no es un JSON válido, conservamos el mensaje genérico
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Capturamos problemas de red (API apagada) o errores de parseo
      print(' CRASH EN API SERVICE: $e');
      throw Exception('No pudimos conectar con el servidor. Verifica tu conexión.');
    }
  }

  // --- CREAR NUEVO PAQUETE TURÍSTICO ---
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token'); // ¡Ojo con la llave que descubriste!

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
        // --- ESCUDO PYDANTIC (Igual que en AuthService) ---
        print(" ERROR FASTAPI (422): ${response.body}");
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
      print(' CRASH EN API SERVICE: $e');
      return {'success': false, 'message': 'Error de conexión con el servidor.'};
    }
  }



}