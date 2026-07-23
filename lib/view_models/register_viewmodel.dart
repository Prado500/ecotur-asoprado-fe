import 'package:flutter/material.dart';
import '../services/tourist_service.dart';

/// ViewModel responsible for orchestrating the registration presentation state.
/// It strictly isolates business logic, memory lifecycle, and domain service calls.
class RegisterViewModel extends ChangeNotifier {
  final TouristService _touristService;

  // Form Controllers strictly managed by the ViewModel to prevent memory leaks in the View.
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Internal reactive state variables
  bool _isLoading = false;
  bool _dataConsent = false;
  String? _errorMessage;
  bool _isSuccess = false;

  /// Injects the domain service dependency.
  RegisterViewModel(this._touristService);

  // Public getters to expose the state immutably to the View.
  bool get isLoading => _isLoading;
  bool get dataConsent => _dataConsent;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Toggles the data consent checkbox state and notifies listeners.
  void setDataConsent(bool value) {
    _dataConsent = value;
    notifyListeners();
  }

  /// Executes the async registration workflow through the domain service.
  Future<void> performRegister() async {
    // 1. Business Logic Validation
    if (!_dataConsent) {
      _setError('Debes aceptar el tratamiento de datos para continuar.');
      return;
    }

    // 2. Loading State Mutation
    _setLoading(true);
    clearError(); // Wipe previous errors before a new attempt

    // 3. Domain Service Execution
    final result = await _touristService.registerTourist(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phoneController.text.trim(),
      dataConsent: _dataConsent,
    );

    // 4. Resolve Loading State
    _setLoading(false);

    // 5. Handle Network Response
    if (result['success']) {
      _isSuccess = true;
      notifyListeners();
    } else {
      _setError(result['message']);
    }
  }

  /// Internal helper to update the loading spinner state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Internal helper to broadcast an error message to the View.
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Explicitly clears the error state without triggering a full listener rebuild.
  /// Crucial for preventing infinite SnackBar loops after the View consumes the error.
  void clearError() {
    _errorMessage = null;
  }

  /// Gracefully destroys the text controllers when the View is popped from the navigation stack.
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}