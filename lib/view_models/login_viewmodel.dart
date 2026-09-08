import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

/// ViewModel responsible for orchestrating the Login presentation state.
/// It synchronizes the stateless [AuthService] operations with the stateful [SessionService].
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  final SessionService _sessionService;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  /// Injects both networking and state management domain dependencies.
  LoginViewModel(this._authService, this._sessionService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Orchestrates the authentication pipeline and session establishment.
  Future<String?> performLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _setError('Please enter your email and password.');
      return null;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _setError('Please enter a valid email address.');
      return null;
    }

    _setLoading(true);
    clearError();

    // 1. Transactional Logic: Delegate network request to the Stateless Service
    final result = await _authService.login(email, password);

    _setLoading(false);

    // 2. State Management: Delegate session persistence to the Stateful Service
    if (result['success']) {
      final token = result['data']['access_token'];
      await _sessionService.establishSession(token);

      return _sessionService.userRole; // Return the extracted role to the View for routing
    } else {
      _setError(result['message']);
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}