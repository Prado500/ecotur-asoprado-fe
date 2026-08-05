import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../view_models/admin_user_form_viewmodel.dart';
import '../widgets/admin/admin_section_card.dart';
import '../widgets/admin/admin_form_field.dart';
import '../utils/ui_helpers.dart';

/// Dumb View acting as the administrative terminal for User Management.
///
/// Subscribes strictly to [AdminUserFormViewModel] and adjusts rendering nodes
/// contextually based on the active bimodal state.
class AdminUserFormScreen extends StatefulWidget {
  final UserService? touristService;
  final UserModel? userToEdit;

  const AdminUserFormScreen({super.key, this.touristService, this.userToEdit});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AdminUserFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminUserFormViewModel(
      widget.touristService ?? UserService(),
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
      final msg = _viewModel.isEditMode ? 'Usuario actualizado exitosamente' : 'Administrador creado exitosamente';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF3B494C)), onPressed: () => Navigator.pop(context)),
        title: Text(_viewModel.isEditMode ? 'EDITAR PERFIL' : 'NUEVO ADMINISTRADOR', style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
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
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(child: AdminFormField(label: 'NOMBRE(S)', hint: 'Nombres', controller: _viewModel.firstNameController)),
                        const SizedBox(width: 16),
                        Expanded(child: AdminFormField(label: 'APELLIDO(S)', hint: 'Apellidos', controller: _viewModel.lastNameController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdminFormField(
                      label: 'TELÉFONO',
                      hint: '3120000000',
                      controller: _viewModel.phoneController,
                      isNumeric: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AdminSectionCard(
                title: 'SEGURIDAD Y ACCESO',
                dotColor: const Color(0xFF6834D1),
                content: Column(
                  children: [
                    AdminFormField(
                      label: 'CORREO ELECTRÓNICO',
                      hint: 'admin@ecotur.com',
                      controller: _viewModel.emailController,
                    ),
                    if (!_viewModel.isEditMode) ...[
                      const SizedBox(height: 16),
                      AdminFormField(
                        label: 'CONTRASEÑA TEMPORAL',
                        hint: 'Mínimo 8 caracteres',
                        controller: _viewModel.passwordController,
                      ),
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
}