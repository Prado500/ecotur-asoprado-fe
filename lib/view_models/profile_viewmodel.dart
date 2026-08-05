import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';

/// ViewModel orchestrating the Profile screen presentation state.
/// It consumes [TouristService] for future data fetching and [SessionService] for session management.
class ProfileViewModel extends ChangeNotifier {
  final SessionService _sessionService;
  final UserService _userService;

  bool _isLoading = false;
  String? _errorMessage;

  /// Injects both the Stateful Session Service and the Stateless Tourist Service.
  ProfileViewModel(this._sessionService, this._userService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Prepares the structure to fetch the user's profile data.
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    // Await _touristService.fetchMyProfile() once the backend endpoint is fully integrated.
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  /// Executes the logout operation and clears the global session state.
  /// The [SessionService] will broadcast this mutation globally.
  Future<void> performLogout() async {
    await _sessionService.destroySession();
  }
}