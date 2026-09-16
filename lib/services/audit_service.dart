import 'package:flutter/foundation.dart';
import '../abstractions/api_client.dart';
import '../models/audit_log_model.dart';

class AuditService {
  final ApiClient _apiClient = ApiClient();

  /// Retrieves a paginated chunk of audit logs, applying optional filtering.
  Future<List<AuditLogModel>> fetchAuditLogs({
    int limit = 20,
    int offset = 0,
    String? entityName,
    String? entityId,
  }) async {
    try {
      // Build dynamic query parameters
      String queryParams = '?limit=$limit&offset=$offset';
      if (entityName != null && entityName.isNotEmpty) queryParams += '&entity_name=$entityName';
      if (entityId != null && entityId.isNotEmpty) queryParams += '&entity_id=$entityId';

      final response = await _apiClient.get('/auditoria/$queryParams');

      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => AuditLogModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      debugPrint('Error in AuditService: $e');
      throw Exception('Fallo de red al cargar el historial de auditoría.');
    }
  }
}