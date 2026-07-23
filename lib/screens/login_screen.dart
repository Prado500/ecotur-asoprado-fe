import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../view_models/login_viewmodel.dart';
import '../utils/ui_helpers.dart';
import '../widgets/common/custom_input.dart';
import '../widgets/common/diagonal_painter.dart';
import 'admin_dashboard_screen.dart';
import 'catalog_screen.dart';
import 'register_screen.dart';

/// Dumb View rendering the Login interface.
/// It strictly listens to the [LoginViewModel] and handles navigation routing based on roles.
class LoginScreen extends StatefulWidget {
  final AuthService? authService;
  final SessionService? sessionService;

  const LoginScreen({super.key, this.authService, this.sessionService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Dependency Injection: Initialize the ViewModel with both required services
    _viewModel = LoginViewModel(
      widget.authService ?? AuthService(),
      widget.sessionService ?? SessionService(),
    );

    // Attach listener for UI side-effects (e.g., SnackBars)
    _viewModel.addListener(_onViewModelChange);
  }

  /// Intercepts ViewModel broadcasts to display errors safely using the BuildContext.
  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      // Consume the error immediately to prevent infinite SnackBar loops
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    // Clean up observers and ViewModel resources
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  /// Commands the ViewModel to perform the login and handles routing upon success.
  void _handleLoginSubmission() async {
    // The ViewModel processes the network transaction and session storage.
    // It returns the user role if successful, or null if it fails.
    final role = await _viewModel.performLogin();

    // Security check to prevent navigation on unmounted contexts
    if (!mounted) return;

    if (role != null) {
      // Route the user based on their specific role (RBAC)
      if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CatalogScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
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
                    bottom: -10,
                    right: -10,
                    child: CustomPaint(size: const Size(120, 120), painter: DiagonalLinesPainter()),
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(height: 6, color: const Color(0xFF006875)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF006875), borderRadius: BorderRadius.circular(6)),
                              child: const Icon(Icons.explore, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text('ECOTUR ASOPRADO', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF001F24), letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('INICIAR SESIÓN', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Ingresa tus datos para acceder a tu cuenta.', style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
                        const SizedBox(height: 32),

                        // Form Inputs bound to the ViewModel's controllers
                        CustomInput(
                          label: 'CORREO ELECTRÓNICO', hint: 'tu@correo.com', icon: Icons.email_outlined,
                          controller: _viewModel.emailController, keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        CustomInput(
                          label: 'CONTRASEÑA', hint: '••••••••', icon: Icons.lock_outline,
                          controller: _viewModel.passwordController, isPassword: true,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () {}, child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF3B494C), fontSize: 12))),
                        ),
                        const SizedBox(height: 20),

                        // --- REACTIVE SUBMIT BUTTON BOUND TO VIEWMODEL ---
                        ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, child) {
                              return SizedBox(
                                width: double.infinity, height: 48,
                                child: ElevatedButton(
                                  onPressed: _viewModel.isLoading ? null : _handleLoginSubmission,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006875), elevation: 0),
                                  child: _viewModel.isLoading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 18)
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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                            child: const Text('Registrarse', style: TextStyle(color: Color(0xFF191C1E), fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
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