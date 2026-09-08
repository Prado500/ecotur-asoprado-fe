import 'package:flutter/material.dart';
import '../services/user_service.dart';

/// ViewModel orchestrating the Admin Dashboard state.
/// Strictly isolates the profile hydration logic from the Dumb View.
class AdminDashboardViewModel extends ChangeNotifier {
  final UserService _userService;

  bool _isLoading = false;
  String? _errorMessage;
  String _firstName = ""; // Will hold the dynamic name

  /// Injects the domain service dependency.
  AdminDashboardViewModel(this._userService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get firstName => _firstName;

  /// Consumes the domain service to fetch the active admin's profile data.
  Future<void> loadAdminProfile() async {
    _isLoading = true;
    notifyListeners();

    final result = await _userService.fetchMyProfile();

    _isLoading = false;

    if (result['success']) {
      // Extract the first name, fallback to 'Admin' if null
      _firstName = result['data']['first_name'] ?? 'ADMIN';
    } else {
      _errorMessage = result['message'];
      _firstName = 'ADMIN'; // Safe fallback for the UI
    }
    notifyListeners();
  }

  /// Explicitly clears the error state to prevent UI notification loops.
  void clearError() {
    _errorMessage = null;
  }
}