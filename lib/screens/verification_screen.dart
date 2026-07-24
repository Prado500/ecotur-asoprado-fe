import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../view_models/verification_viewmodel.dart';
import '../widgets/common/diagonal_painter.dart';
import '../utils/ui_helpers.dart';
import 'login_screen.dart';

/// Dumb View rendering the email verification interface.
/// It intercepts the token from the URL and delegates validation to [VerificationViewModel].
class VerificationScreen extends StatefulWidget {
  final String token;
  final AuthService? authService;

  const VerificationScreen({super.key, required this.token, this.authService});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final VerificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Dependency Injection
    _viewModel = VerificationViewModel(widget.authService ?? AuthService(), widget.token);
    _viewModel.addListener(_onViewModelChange);
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
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
                    bottom: -10, right: -10,
                    child: CustomPaint(size: const Size(120, 120), painter: DiagonalLinesPainter()),
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(height: 6, color: const Color(0xFF006875)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
                    child: ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, child) {
                          if (_viewModel.isSuccess) {
                            return _buildSuccessState();
                          }
                          return _buildVerificationState();
                        }
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

  Widget _buildVerificationState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF006875).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, size: 48, color: Color(0xFF006875)),
        ),
        const SizedBox(height: 24),
        Text('VERIFICACIÓN DE SEGURIDAD', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('Estás a un paso de activar tu cuenta en Ecotur Asoprado. Haz clic en el botón inferior para validar tu identidad.', style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: _viewModel.isLoading ? null : _viewModel.performVerification,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C49), elevation: 0),
            child: _viewModel.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Verificar mi Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF006C49).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF006C49)),
        ),
        const SizedBox(height: 24),
        Text('¡CUENTA ACTIVADA!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, color: const Color(0xFF006C49)), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('Tu correo electrónico ha sido verificado con éxito. Ya tienes acceso completo a nuestra plataforma.', style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF006875), width: 1.5)),
            child: const Text('Ir al Inicio de Sesión', style: TextStyle(color: Color(0xFF006875), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}