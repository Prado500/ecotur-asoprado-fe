class AuditLogModel {
  final int id;
  final String entityName;
  final String entityId;
  final String action;
  final Map<String, dynamic>? changes;
  final String performedBy;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.entityName,
    required this.entityId,
    required this.action,
    this.changes,
    required this.performedBy,
    required this.timestamp,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] ?? 0,
      entityName: json['entity_name'] ?? 'Desconocida',
      entityId: json['entity_id'] ?? '',
      action: json['action'] ?? 'UNKNOWN',
      changes: json['changes'], // Maps as dynamic Dict natively
      performedBy: json['performed_by'] ?? 'Sistema',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}