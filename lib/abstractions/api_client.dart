import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

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

  /// Executes an HTTP GET request with automatic token injection.
  Future<Map<String, dynamic>> get(String endpoint) async {
    return _request('GET', endpoint);
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
      return {'success': false, 'message': 'Network connection failed.'};
    }
  }

  /// Standardizes error responses from the FastAPI backend.
  Map<String, dynamic> _handleApiError(http.Response response) {
    try {
      final data = json.decode(utf8.decode(response.bodyBytes));
      String errorMessage = 'Server error (Code: ${response.statusCode})';

      if (data['detail'] != null) {
        if (data['detail'] is List && data['detail'].isNotEmpty) {
          final firstError = data['detail'][0] as Map<String, dynamic>;
          final locList = firstError['loc'] as List<dynamic>?;
          final msg = firstError['msg']?.toString() ?? 'Validation error';
          String fieldName = (locList != null && locList.isNotEmpty) ? locList.last.toString() : 'Field';
          errorMessage = "$fieldName: $msg";
        } else if (data['detail'] is String) {
          errorMessage = data['detail'];
        }
      }
      return {'success': false, 'message': errorMessage};
    } catch (_) {
      return {'success': false, 'message': 'Unexpected server error (Code: ${response.statusCode})'};
    }
  }
}