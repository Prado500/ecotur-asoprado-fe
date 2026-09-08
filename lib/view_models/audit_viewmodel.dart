import 'package:flutter/material.dart';
import '../services/audit_service.dart';
import '../models/audit_log_model.dart';

class AuditViewModel extends ChangeNotifier {
  final AuditService _auditService;

  // In-Memory State Cache
  final List<AuditLogModel> _logs = [];

  // Pagination Cursors
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMoreData = true; // Flag to stop fetching if DB returns < 20 records

  // Filtering State
  String? _activeEntityName;
  String? _activeEntityId;

  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;

  AuditViewModel(this._auditService);

  List<AuditLogModel> get logs => _logs;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  /// Initial load or filter application. Purges existing cache.
  Future<void> loadLogs({String? entityName, String? entityId}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentOffset = 0;
    _activeEntityName = entityName;
    _activeEntityId = entityId;
    _hasMoreData = true;
    notifyListeners();

    try {
      final fetchedLogs = await _auditService.fetchAuditLogs(
        limit: _limit,
        offset: _currentOffset,
        entityName: _activeEntityName,
        entityId: _activeEntityId,
      );

      _logs.clear(); // Purge cache on fresh load
      _logs.addAll(fetchedLogs);

      if (fetchedLogs.length < _limit) _hasMoreData = false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appends the next chunk of logs to the existing cache (Infinite Scroll).
  Future<void> loadMoreLogs() async {
    if (_isFetchingMore || !_hasMoreData) return;

    _isFetchingMore = true;
    _currentOffset += _limit; // Advance cursor
    notifyListeners();

    try {
      final fetchedLogs = await _auditService.fetchAuditLogs(
        limit: _limit,
        offset: _currentOffset,
        entityName: _activeEntityName,
        entityId: _activeEntityId,
      );

      _logs.addAll(fetchedLogs); // Append to cache

      if (fetchedLogs.length < _limit) _hasMoreData = false;
    } catch (e) {
      _currentOffset -= _limit; // Rollback cursor on failure
      _errorMessage = 'Error al cargar más registros.';
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
  }
}