import 'package:ecotur_app/screens/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'catalog_screen.dart';
import 'register_screen.dart';
// TODO: Importar la pantalla de Admin cuando la creemos
// import 'admin_dashboard_screen.dart';

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
  bool _obscurePassword = true;

  void _handleLogin() async {
    // 1. Validación temprana para evitar peticiones vacías al backend
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingresa tu correo y contraseña.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // --- 2. VALIDACIÓN TEMPRANA DEL CORREO (Regex) ---
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingresa un correo electrónico válido (ej: usuario@correo.com).'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return; // Detenemos la ejecución aquí mismo
    }

    // --- 3. VALIDACIÓN TEMPRANA DE LA CONTRASEÑA ---
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La contraseña debe tener al menos 8 caracteres.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return; // Detenemos la ejecución aquí mismo
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        final String role = result['role']; // Leemos el rol del token
        if (!mounted) return;

        // EL ENRUTADOR BASADO EN ROLES
        if (role == 'admin') {
          // Por ahora redirigimos al catálogo hasta que hagamos la pantalla admin
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboardScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CatalogScreen()));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error de conexión al servidor.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Fondo claro del Design System
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            // --- CONTENEDOR PRINCIPAL (Reemplaza al Card genérico) ---
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // --- DECORACIÓN: Las líneas diagonales grises ---
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: CustomPaint(
                      size: const Size(120, 120),
                      painter: DiagonalLinesPainter(),
                    ),
                  ),

                  // --- DECORACIÓN: La franja Cyan/Verde superior ---
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      color: const Color(0xFF006875), // Primary Color
                    ),
                  ),

                  // --- FORMULARIO ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Encabezado alineado horizontalmente
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006875),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.explore, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ECOTUR ASOPRADO',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF001F24),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                            'INICIAR SESIÓN',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa tus datos para acceder a tu cuenta.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Inputs estilo Minimalista (Solo línea inferior)
                        _buildCustomInput(
                          label: 'CORREO ELECTRÓNICO',
                          hint: 'tu@correo.com',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),

                        _buildCustomInput(
                          label: 'CONTRASEÑA',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          isPassword: true,
                        ),

                        // Link de recuperación
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF3B494C), fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Botón Iniciar Sesión
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006875),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Botón Registrarse
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
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

  // Creador de Inputs Personalizados
  Widget _buildCustomInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3B494C), letterSpacing: 0.5)
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: const Color(0xFF6B7A7D)),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF6B7A7D)),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
            // Bordes minimalistas: solo la línea inferior
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF006875), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: false,
          ),
        ),
      ],
    );
  }
}

// --- CLASE PARA DIBUJAR LAS LÍNEAS DIAGONALES ---
class DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBAC9CC).withOpacity(0.4) // Color sutil de las líneas
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double spacing = 18.0;

    for (int i = 0; i < 7; i++) {
      final offset = i * spacing;
      canvas.drawLine(
        Offset(size.width - offset, size.height), // Abajo
        Offset(size.width, size.height - offset), // Derecha
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}