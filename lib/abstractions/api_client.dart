import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http_parser/http_parser.dart';
import 'package:cross_file/cross_file.dart';

/// Centralized HTTP client abstraction.
/// Handles base URL resolution, JWT token injection, and standard error parsing.
class ApiClient {
  static const String _tokenKey = 'jwt_token';

  /// Resolves the base URL dynamically based on the environment (CI/CD or local).
  String get _baseUrl {
    const String pipelineUrl = String.fromEnvironment('API_URL');
    if (pipelineUrl.isNotEmpty) return pipelineUrl;

    String url = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    if (!kIsWeb && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }

  /// Executes an HTTP POST request with automatic token injection.
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    return _request('POST', endpoint, body: body);
  }

  /// Executes a multipart/form-data POST request for binary file uploads.
  Future<Map<String, dynamic>> postMultipart(
      String endpoint,
      Map<String, String> fields,
      List<XFile> files
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      final uri = Uri.parse('$_baseUrl$endpoint');
      var request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Inject standard string fields
      request.fields.addAll(fields);

      // Inject binary streams
      for (var file in files) {
        final byteStream = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            byteStream,
            filename: file.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedData = response.bodyBytes.isNotEmpty ? json.decode(utf8.decode(response.bodyBytes)) : {};
        return {'success': true, 'data': decodedData};
      } else {
        return _handleApiError(response);
      }
    } catch (e) {
      debugPrint('HTTP Multipart Client Error: $e');
      return {'success': false, 'message': 'Falla al procesar la subida de archivos.'};
    }
  }

  /// Executes an HTTP GET request with automatic token injection.
  Future<Map<String, dynamic>> get(String endpoint) async {
    return _request('GET', endpoint);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    return _request('PUT', endpoint, body: body);
  }

  Future<Map<String, dynamic>> patch(String endpoint, {Map<String, dynamic>? body}) async {
    return _request('PATCH', endpoint, body: body);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _request('DELETE', endpoint);
  }

  /// Internal method to handle the actual HTTP request and response parsing.
  Future<Map<String, dynamic>> _request(String method, String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('$_baseUrl$endpoint');
      http.Response response;

      if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: json.encode(body));
      } else if (method == 'PUT') {
        response = await http.put(uri, headers: headers, body: json.encode(body));
      } else if (method == 'PATCH') {
        response = await http.patch(uri, headers: headers, body: body != null ? json.encode(body) : null);
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers);
      } else {
        response = await http.get(uri, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedData = response.bodyBytes.isNotEmpty ? json.decode(utf8.decode(response.bodyBytes)) : {};
        return {'success': true, 'data': decodedData};
      } else {
        return _handleApiError(response);
      }
    } catch (e) {
      debugPrint('HTTP Client Error: $e');
      return {'success': false, 'message': 'Falla de conexión a la red. Verifique su internet.'};
    }
  }

  /// Standardizes error responses from the FastAPI backend.
  /// Intelligently parses both standard HTTPExceptions ('detail') and custom Pydantic handlers ('detalle').
  Map<String, dynamic> _handleApiError(http.Response response) {
    try {
      final data = json.decode(utf8.decode(response.bodyBytes));
      String errorMessage = 'Error en el servidor (Código: ${response.statusCode})';

      // 1. Customized exception handling (Pydantic RequestValidationError)
      //  Backend JSON response to this kind of exception: {"detalle": [{"raw_field": "...", "message": "..."}]}
      if (data['detalle'] != null && data['detalle'] is List && (data['detalle'] as List).isNotEmpty) {
        final firstError = data['detalle'][0] as Map<String, dynamic>;
        errorMessage = firstError['message']?.toString() ?? 'Error de validación en el formulario.';
        return {'success': false, 'message': errorMessage};
      }

      // 2. Standard exception handling (FastAPI HTTPExceptions / IntegrityError)
      // Backend JSON response to this kind of exception: {"detail": "Su sesión ha expirado..."}
      if (data['detail'] != null) {
        if (data['detail'] is String) {
          errorMessage = data['detail'];
        } else if (data['detail'] is List && (data['detail'] as List).isNotEmpty) {
          // Fallback if there ever is a native 422 exception code uncaught by both handlers.
          final firstError = data['detail'][0] as Map<String, dynamic>;
          errorMessage = firstError['msg']?.toString() ?? 'Error de validación.';
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (_) {
      return {'success': false, 'message': 'Error inesperado del servidor (Código: ${response.statusCode})'};
    }
  }
}