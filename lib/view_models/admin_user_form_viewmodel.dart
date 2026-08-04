import 'package:flutter/material.dart';
import '../services/tourist_service.dart';
import '../models/user_model.dart';

/// ViewModel orchestrating the Bimodal User Edition form presentation state.
///
/// Implements differential payload generation depending on the active mode
/// (Create vs. Update) to satisfy strict Pydantic DTO boundaries and guarantee
/// zero technical debt regarding administrative provisioning.
class AdminUserFormViewModel extends ChangeNotifier {
  final TouristService _touristService;
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

  /// Injects the domain service and pre-fills form controllers if operating in Edit Mode.
  AdminUserFormViewModel(this._touristService, {this.userToEdit}) {
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

  /// Evaluates the presence of an injected entity to determine the operational mode.
  bool get isEditMode => userToEdit != null;

  /// Generates a strict schema payload excluding immutable parameters.
  ///
  /// Deliberately omits 'role', 'is_active', and 'cedula' to comply with the
  /// UserUpdate DTO and prevent unauthorized Privilege Escalation.
  Map<String, dynamic> _buildUpdatePayload() {
    return {
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "email": emailController.text.trim(),
    };
  }

  /// Generates a complete creation payload inclusive of cryptographic requirements.
  Map<String, dynamic> _buildCreationPayload() {
    return {
      "cedula": cedulaController.text.trim(),
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "role": "admin", // Bypasses the tourist default
      "data_consent": true, // Architecturally assumed for administrative provisioning
      "is_active": true, // Immediately active
    };
  }

  /// Dispatches the creation payload bypassing standard registration limitations.
  Future<void> saveUser() async {
    _setLoading(true);
    clearError();

    final payload = _buildCreationPayload();
    final result = await _touristService.createAdminUser(payload);

    _handleResponse(result);
  }

  /// Dispatches the partial update payload utilizing the immutable [cedula] as the target identifier.
  Future<void> updateUser() async {
    if (userToEdit == null) return;
    _setLoading(true);
    clearError();

    final payload = _buildUpdatePayload();
    final result = await _touristService.updateUser(userToEdit!.cedula, payload);

    _handleResponse(result);
  }

  /// Centralizes networking response parsing and state emission.
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

  /// Safely clears active error messages preventing notification loops.
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