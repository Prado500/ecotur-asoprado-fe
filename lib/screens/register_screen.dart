import 'package:flutter/material.dart';
import '../services/tourist_service.dart';
import '../view_models/register_viewmodel.dart';
import '../utils/ui_helpers.dart';
import '../widgets/common/custom_input.dart';

/// Dumb View rendering the registration interface.
/// It strictly listens to the [RegisterViewModel] and paints UI states accordingly.
class RegisterScreen extends StatefulWidget {
  final TouristService? touristService;

  const RegisterScreen({super.key, this.touristService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Dependency Injection: Initialize ViewModel with the specific Domain Service
    _viewModel = RegisterViewModel(widget.touristService ?? TouristService());

    // Attach the context-safe observer to listen for side-effects (Errors/Success)
    _viewModel.addListener(_onViewModelChange);
  }

  /// Intercepts ViewModel broadcasts to trigger one-off UI events (like SnackBars).
  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      // Consume the error immediately to prevent infinite SnackBar loops
      _viewModel.clearError();
    }

    if (_viewModel.isSuccess) {
      UIHelpers.showSnackBar(context, '¡Cuenta creada exitosamente! Ahora inicia sesión.', isError: false);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Detach listeners and destroy ViewModel resources safely
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  /// Triggers the synchronous visual validation before commanding the ViewModel.
  void _handleRegisterSubmission() {
    if (!_formKey.currentState!.validate()) return;
    _viewModel.performRegister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'ECOTUR ASOPRADO',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF006875),
              letterSpacing: 1.2,
            )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF191C1E)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF006875), Color(0xFF006C49)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('REGISTRO', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28, fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold)),
                          const SizedBox(height: 32),

                          Row(
                            children: [
                              Expanded(
                                child: CustomInput(
                                  label: 'NOMBRE(S)', hint: 'Ej. Juan', icon: Icons.person_outline,
                                  controller: _viewModel.firstNameController,
                                  validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomInput(
                                  label: 'APELLIDO(S)', hint: 'Ej. Pérez', icon: Icons.badge_outlined,
                                  controller: _viewModel.lastNameController,
                                  validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // --- FAIL-FAST CLIENT-SIDE VALIDATION FOR CÉDULA ---
                          CustomInput(
                            label: 'CÉDULA DE CIUDADANÍA', hint: 'Ej. 1005911792', icon: Icons.badge_outlined,
                            controller: _viewModel.cedulaController, keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Requerido';
                              final cedulaRegex = RegExp(r'^\d{6,10}$');
                              if (!cedulaRegex.hasMatch(val)) return 'Solo números (6 a 10 dígitos)';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          CustomInput(
                            label: 'TELÉFONO', hint: 'Ej. 3124273211', icon: Icons.phone_outlined,
                            controller: _viewModel.phoneController, keyboardType: TextInputType.phone,
                            validator: (val) => val == null || val.length < 7 ? 'Teléfono inválido' : null,
                          ),
                          const SizedBox(height: 24),

                          CustomInput(
                            label: 'CORREO ELECTRÓNICO', hint: 'tu@email.com', icon: Icons.email_outlined,
                            controller: _viewModel.emailController, keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Requerido';
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(val)) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          CustomInput(
                            label: 'DEFINIR CONTRASEÑA', hint: 'Crea una contraseña', icon: Icons.lock_outline,
                            controller: _viewModel.passwordController, isPassword: true,
                            validator: (val) => val == null || val.length < 8 ? 'Mínimo 8 caracteres' : null,
                          ),
                          const SizedBox(height: 24),

                          // --- REACTIVE CHECKBOX BOUND TO VIEWMODEL ---
                          ListenableBuilder(
                              listenable: _viewModel,
                              builder: (context, child) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24, height: 24,
                                      child: Checkbox(
                                        value: _viewModel.dataConsent,
                                        activeColor: const Color(0xFF006875),
                                        onChanged: (value) => _viewModel.setDataConsent(value ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Acepto la política de privacidad y el tratamiento de mis datos personales.',
                                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                      ),
                                    ),
                                  ],
                                );
                              }
                          ),
                          const SizedBox(height: 32),

                          // --- REACTIVE SUBMIT BUTTON BOUND TO VIEWMODEL ---
                          ListenableBuilder(
                              listenable: _viewModel,
                              builder: (context, child) {
                                return SizedBox(
                                  width: double.infinity, height: 48,
                                  child: ElevatedButton(
                                    onPressed: _viewModel.isLoading ? null : _handleRegisterSubmission,
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006875), elevation: 0),
                                    child: _viewModel.isLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Crear mi Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity, height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login, size: 18, color: Color(0xFF3B494C)),
                                  SizedBox(width: 8),
                                  Text('Volver al Inicio de Sesión', style: TextStyle(color: Color(0xFF3B494C), fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}