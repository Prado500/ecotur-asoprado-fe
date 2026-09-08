import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// ViewModel responsible for orchestrating the Email Verification presentation state.
/// It strictly isolates business logic and network delegation from the Dumb View.
class VerificationViewModel extends ChangeNotifier {
  final AuthService _authService;
  final String token;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  /// Injects the domain service dependency and the cryptographic token.
  VerificationViewModel(this._authService, this.token);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Executes the async verification workflow through the domain service.
  Future<void> performVerification() async {
    _setLoading(true);
    clearError();

    final result = await _authService.verifyEmail(token);

    _setLoading(false);

    if (result['success']) {
      _isSuccess = true;
      notifyListeners();
    } else {
      _setError(result['message']);
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
}