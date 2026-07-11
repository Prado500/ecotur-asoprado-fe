import 'package:flutter/material.dart';

/// ViewModel responsible for orchestrating the Admin Dashboard state.
/// Prepares the presentation layer for future asynchronous KPI fetching.
class AdminDashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Mocked state for future backend integration
  String _activePackages = '124';
  String _pendingReservations = '38';
  String _conversionRate = '24%';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activePackages => _activePackages;
  String get pendingReservations => _pendingReservations;
  String get conversionRate => _conversionRate;

  /// Simulates an asynchronous data fetch for the dashboard KPIs.
  /// To be wired to a domain service (e.g., AnalyticsService) in future sprints.
  Future<void> loadDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with real domain service call
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulated dynamic data update
      _activePackages = '125';

    } catch (e) {
      _errorMessage = 'Failed to load live statistics.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Explicitly clears the error state to prevent UI notification loops.
  void clearError() {
    _errorMessage = null;
  }
}