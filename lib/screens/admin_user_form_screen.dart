import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/session_service.dart';
import '../models/user_model.dart';
import '../view_models/admin_user_form_viewmodel.dart';
import '../widgets/admin/admin_section_card.dart';
import '../widgets/admin/admin_form_field.dart';
import '../utils/ui_helpers.dart';

/// Dumb View acting as the administrative terminal for User Management.
///
/// Adjusts rendering nodes contextually based on the active bimodal state
/// and the authenticated user's RBAC hierarchical claims.
class AdminUserFormScreen extends StatefulWidget {
  final UserService? userService;
  final SessionService? sessionService;
  final UserModel? userToEdit;

  const AdminUserFormScreen({super.key, this.userService, this.sessionService, this.userToEdit});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AdminUserFormViewModel _viewModel;
  late final SessionService _sessionService;

  @override
  void initState() {
    super.initState();
    _sessionService = widget.sessionService ?? SessionService();

    // Asynchronously resolve role claims to adapt UI rendering
    _sessionService.checkExistingSession();

    _viewModel = AdminUserFormViewModel(
      widget.userService ?? UserService(),
      _sessionService,
      userToEdit: widget.userToEdit,
    );
    _viewModel.addListener(_onViewModelChange);
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      _viewModel.clearError();
    }

    if (_viewModel.isSuccess) {
      final msg = _viewModel.isEditMode ? 'Usuario actualizado exitosamente' : 'Cuenta de usuario aprovisionada con éxito';
      UIHelpers.showSnackBar(context, msg, isError: false);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    _viewModel.isEditMode ? _viewModel.updateUser() : _viewModel.saveUser();
  }

  @override
  Widget build(BuildContext context) {
    // Observing SessionService guarantees the UI reacts if role claims shift
    return ListenableBuilder(
        listenable: _sessionService,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FB),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF3B494C)), onPressed: () => Navigator.pop(context)),
              title: Text(_viewModel.isEditMode ? 'EDITAR PERFIL' : 'NUEVO USUARIO', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AdminSectionCard(
                      title: 'INFORMACIÓN PERSONAL',
                      dotColor: const Color(0xFF006875),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_viewModel.isEditMode) ...[
                            AdminFormField(
                              label: 'CÉDULA DE CIUDADANÍA',
                              hint: 'Ej. 1005911792',
                              controller: _viewModel.cedulaController,
                              isNumeric: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Requerido';
                                if (!RegExp(r'^\d{6,10}$').hasMatch(val.trim())) return 'Entre 6 y 10 dígitos numéricos';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: AdminFormField(
                                  label: 'NOMBRE(S)', hint: 'Nombres', controller: _viewModel.firstNameController,
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AdminFormField(
                                  label: 'APELLIDO(S)', hint: 'Apellidos', controller: _viewModel.lastNameController,
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AdminFormField(
                            label: 'TELÉFONO',
                            hint: '3120000000',
                            controller: _viewModel.phoneController,
                            isNumeric: true,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Requerido';
                              if (!RegExp(r'^3\d{9}$').hasMatch(val.trim())) return 'Debe iniciar con 3 y tener 10 dígitos';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AdminSectionCard(
                      title: 'SEGURIDAD Y ACCESO',
                      dotColor: const Color(0xFF6834D1),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AdminFormField(
                            label: 'CORREO ELECTRÓNICO',
                            hint: 'usuario@ecotur.com',
                            controller: _viewModel.emailController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Requerido';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) return 'Correo inválido';
                              return null;
                            },
                          ),
                          if (!_viewModel.isEditMode) ...[
                            const SizedBox(height: 16),
                            AdminFormField(
                              label: 'CONTRASEÑA TEMPORAL',
                              hint: 'Mínimo 8 caracteres, 1 mayúscula, 1 número',
                              controller: _viewModel.passwordController,
                              validator: (val) {
                                if (val == null || val.length < 8) return 'Mínimo 8 caracteres';
                                if (!val.contains(RegExp(r'[A-Z]'))) return 'Falta mayúscula';
                                if (!val.contains(RegExp(r'[0-9]'))) return 'Falta número';
                                return null;
                              },
                            ),

                            // --- CONDITIONAL RBAC ROLE RENDERING ---
                            if (_viewModel.isSuperAdmin) ...[
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text('ROL DEL USUARIO (Exclusivo Superadmin)', style: TextStyle(fontSize: 12, color: Color(0xFF3B494C), fontWeight: FontWeight.bold)),
                              ),
                              ListenableBuilder(
                                  listenable: _viewModel,
                                  builder: (context, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBAC9CC)), borderRadius: BorderRadius.circular(4)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _viewModel.selectedRole,
                                          items: ['superadmin', 'admin', 'tourist'].map((String value) {
                                            return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
                                          }).toList(),
                                          onChanged: (val) => _viewModel.setRole(val!),
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            ],
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]),
              child: SafeArea(
                child: ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      return ElevatedButton.icon(
                        onPressed: _viewModel.isLoading ? null : _handleSubmit,
                        icon: _viewModel.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save, color: Colors.white, size: 18),
                        label: Text(_viewModel.isEditMode ? 'ACTUALIZAR DATOS' : 'CREAR CUENTA', style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C49), padding: const EdgeInsets.symmetric(vertical: 16)),
                      );
                    }
                ),
              ),
            ),
          );
        }
    );
  }
}