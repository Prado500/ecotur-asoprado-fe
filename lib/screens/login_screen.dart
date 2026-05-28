import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_input.dart';
import '../widgets/diagonal_painter.dart';
import 'admin_dashboard_screen.dart';
import 'catalog_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError('Por favor, ingresa tu correo y contraseña.');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showError('Por favor, ingresa un correo electrónico válido (ej: usuario@correo.com).');
      return;
    }

    if (_passwordController.text.length < 8) {
      _showError('La contraseña debe tener al menos 8 caracteres.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        if (!mounted) return;
        final String role = result['role'];

        if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CatalogScreen()));
        }
      } else {
        if (!mounted) return;
        _showError(result['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showError('Error de conexión al servidor.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
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

                        CustomInput(
                          label: 'CORREO ELECTRÓNICO', hint: 'tu@correo.com', icon: Icons.email_outlined,
                          controller: _emailController, keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        CustomInput(
                          label: 'CONTRASEÑA', hint: '••••••••', icon: Icons.lock_outline,
                          controller: _passwordController, isPassword: true,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () {}, child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF3B494C), fontSize: 12))),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity, height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006875), elevation: 0),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)]),
                          ),
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