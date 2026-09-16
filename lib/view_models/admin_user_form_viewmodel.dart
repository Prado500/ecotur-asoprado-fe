import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/session_service.dart';
import '../models/user_model.dart';

/// ViewModel orchestrating the Bimodal User Edition form presentation state.
///
/// Contextually evaluates the current session claims (Superadmin vs Admin)
/// to dynamically route payloads to either the administrative provisioning endpoint
/// or the standard public registration pipeline.
class AdminUserFormViewModel extends ChangeNotifier {
  final UserService _userService;
  final SessionService _sessionService;
  final UserModel? userToEdit;

  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;
  String _selectedRole = 'tourist'; // Default fallback

  /// Injects domain services and evaluates the presence of an injected entity.
  AdminUserFormViewModel(this._userService, this._sessionService, {this.userToEdit}) {
    if (userToEdit != null) {
      cedulaController.text = userToEdit!.cedula;
      firstNameController.text = userToEdit!.firstName;
      lastNameController.text = userToEdit!.lastName;
      phoneController.text = userToEdit!.phone ?? '';
      emailController.text = userToEdit!.email;
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  String get selectedRole => _selectedRole;

  bool get isEditMode => userToEdit != null;
  bool get isSuperAdmin => _sessionService.userRole == 'superadmin';

  /// Mutates the selected hierarchical role during creation mode.
  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  /// Generates a strict schema payload excluding immutable parameters.
  Map<String, dynamic> _buildUpdatePayload() {
    return {
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "email": emailController.text.trim(),
    };
  }

  /// Generates a complete creation payload inclusive of the dynamically selected role.
  Map<String, dynamic> _buildAdminCreationPayload() {
    return {
      "cedula": cedulaController.text.trim(),
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "role": _selectedRole,
      "data_consent": true,
      "is_active": true,
    };
  }

  /// Evaluates RBAC constraints to dispatch the creation request to the appropriate backend endpoint.
  Future<void> saveUser() async {
    _setLoading(true);
    clearError();

    Map<String, dynamic> result;

    if (isSuperAdmin) {
      // Superadmins bypass public pipelines and provision active accounts directly.
      final payload = _buildAdminCreationPayload();
      result = await _userService.createAdminUser(payload);
    } else {
      // Standard Admins fall back to the public registration pipeline.
      // This enforces the 'tourist' role and triggers standard backend email verifications.
      result = await _userService.registerTourist(
        cedula: cedulaController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        dataConsent: true,
      );
    }

    _handleResponse(result);
  }

  /// Dispatches the partial update payload targeting the immutable [cedula].
  Future<void> updateUser() async {
    if (userToEdit == null) return;
    _setLoading(true);
    clearError();

    final payload = _buildUpdatePayload();
    final result = await _userService.updateUser(userToEdit!.cedula, payload);

    _handleResponse(result);
  }

  void _handleResponse(Map<String, dynamic> result) {
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

  void clearError() => _errorMessage = null;

  @override
  void dispose() {
    cedulaController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}