import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _dataConsent = false; // Estado para el checkbox de Pydantic

  void _handleRegister() async {
    // 1. Validar que no haya campos vacíos
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, completa todos los campos.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

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


    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La contraseña debe tener al menos 8 caracteres.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return; // Detenemos la ejecución aquí mismo
    }

    // 2. Validar que aceptó el tratamiento de datos (data_consent)
    if (!_dataConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes aceptar el tratamiento de datos para continuar.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _dataConsent,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Cuenta creada exitosamente! Ahora inicia sesión.'),
              backgroundColor: Color(0xFF006C49)
          ),
        );
        Navigator.pop(context); // Vuelve al Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error de conexión al registrar.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('REGISTRO', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28)),
                        const SizedBox(height: 32),

                        // Nombres y Apellidos en fila para ahorrar espacio
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomInput(
                                label: 'NOMBRE(S)',
                                hint: 'Ej. Juan',
                                icon: Icons.person_outline,
                                controller: _firstNameController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCustomInput(
                                label: 'APELLIDO(S)',
                                hint: 'Ej. Pérez',
                                icon: Icons.badge_outlined,
                                controller: _lastNameController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Teléfono
                        _buildCustomInput(
                          label: 'TELÉFONO',
                          hint: 'Ej. 3124273211',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),

                        // Correo
                        _buildCustomInput(
                          label: 'CORREO ELECTRÓNICO',
                          hint: 'tu@email.com',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),

                        // Contraseña
                        _buildCustomInput(
                          label: 'DEFINIR CONTRASEÑA',
                          hint: 'Crea una contraseña',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          isPassword: true,
                        ),

                        const SizedBox(height: 24),

                        // Checkbox para data_consent (¡Clave para Pydantic!)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _dataConsent,
                                activeColor: const Color(0xFF006875),
                                onChanged: (value) {
                                  setState(() => _dataConsent = value ?? false);
                                },
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
                        ),
                        const SizedBox(height: 32),

                        // Botón Registro
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006875),
                              elevation: 0,
                            ),
                            child: _isLoading
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
                        ),
                        const SizedBox(height: 12),

                        // Botón Volver
                        SizedBox(
                          width: double.infinity,
                          height: 48,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF6B7A7D)),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF6B7A7D)),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
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