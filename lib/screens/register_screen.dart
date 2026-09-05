import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../view_models/register_viewmodel.dart';
import '../utils/ui_helpers.dart';
import '../widgets/common/custom_input.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'login_screen.dart';

/// Dumb View rendering the registration interface.
/// It strictly listens to the [RegisterViewModel] and paints UI states accordingly.
class RegisterScreen extends StatefulWidget {
  final UserService? userService;

  const RegisterScreen({super.key, this.userService});

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
    _viewModel = RegisterViewModel(widget.userService ?? UserService());

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
      UIHelpers.showSnackBar(context, '¡Cuenta creada exitosamente! Revise su correo electrónico e inicie sesión.', isError: false);
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
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          return isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context);
        },
      ),
    );
  }

  /// ------------------------------------------------------------------
  /// MÓVIL: misma cabecera naranja con logo circular que el login, y
  /// debajo la tarjeta blanca con el formulario de registro.
  /// ------------------------------------------------------------------
  Widget _buildMobileLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.26;
    final logoSize = (size.width * 0.28).clamp(90.0, 130.0);

    return Stack(
      children: [
        Column(
          children: [
            // --- Cabecera naranja clara ---
            Container(
              width: double.infinity,
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent.withOpacity(0.55), AppColors.accent.withOpacity(0.35)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            'ECOTUR ASOPRADO',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (logoSize / 2) + 16),
                    ],
                  ),
                ),
              ),
            ),

            // --- Tarjeta blanca con el formulario de registro ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(28, (logoSize / 2) + 20, 28, 32),
                  child: _buildFormBody(context, showWordmark: false),
                ),
              ),
            ),
          ],
        ),

        // --- Logo circular, montado sobre el límite cabecera/tarjeta ---
        Positioned(
          top: headerHeight - (logoSize / 2),
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: logoSize,
              height: logoSize,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/prado_splash.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ------------------------------------------------------------------
  /// ESCRITORIO/TABLET: imagen fija a la izquierda, formulario a la
  /// derecha — igual estructura que el login.
  /// ------------------------------------------------------------------
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/prado_splash.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.35)],
                  ),
                ),
              ),
              Positioned(
                left: 40,
                bottom: 48,
                right: 40,
                child: Row(
                  children: [
                    const Icon(Icons.explore, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Text('ECOTUR ASOPRADO', style: AppTextStyles.brandWordmark.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildFormBody(context, showWordmark: false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ------------------------------------------------------------------
  /// Formulario de registro — compartido entre móvil y escritorio.
  /// ------------------------------------------------------------------
  Widget _buildFormBody(BuildContext context, {bool showWordmark = true}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showWordmark) ...[
            const Text('ECOTUR ASOPRADO', style: AppTextStyles.brandWordmark, textAlign: TextAlign.center),
            const SizedBox(height: 18),
          ],

          // Selector INICIAR SESIÓN / REGISTRO — con REGISTRO activo.
          _AuthTabSwitcher(
            onTapLogin: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
          const SizedBox(height: 24),

          Text.rich(
            TextSpan(
              style: AppTextStyles.displayTitle,
              children: [
                const TextSpan(text: 'Crea tu '),
                TextSpan(text: 'cuenta', style: AppTextStyles.displayTitle.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Regístrate para empezar a explorar Prado-Tolima.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: _PillInput(
                  hint: 'Nombre(s)',
                  icon: Icons.person_outline,
                  controller: _viewModel.firstNameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Requerido';
                    if (val.trim().length < 2) return 'Mínimo 2 letras';
                    final nameRegex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÜüÑñ]+(?:\s[A-Za-zÁÉÍÓÚáéíóúÜüÑñ]+)*$');
                    if (!nameRegex.hasMatch(val.trim())) return 'Solo letras';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PillInput(
                  hint: 'Apellido(s)',
                  icon: Icons.badge_outlined,
                  controller: _viewModel.lastNameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Requerido';
                    if (val.trim().length < 2) return 'Mínimo 2 letras';
                    final nameRegex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÜüÑñ]+(?:\s[A-Za-zÁÉÍÓÚáéíóúÜüÑñ]+)*$');
                    if (!nameRegex.hasMatch(val.trim())) return 'Solo letras';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _PillInput(
            hint: 'Cédula de ciudadanía',
            icon: Icons.badge_outlined,
            controller: _viewModel.cedulaController,
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Requerido';
              final cedulaRegex = RegExp(r'^\d{6,10}$');
              if (!cedulaRegex.hasMatch(val.trim())) return 'Solo numérico (6 a 10 dígitos)';
              return null;
            },
          ),
          const SizedBox(height: 14),

          _PillInput(
            hint: 'Teléfono',
            icon: Icons.phone_outlined,
            controller: _viewModel.phoneController,
            keyboardType: TextInputType.phone,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Requerido';
              final phoneRegex = RegExp(r'^3\d{9}$');
              if (!phoneRegex.hasMatch(val.trim())) return 'Debe iniciar con 3 y tener 10 dígitos';
              return null;
            },
          ),
          const SizedBox(height: 14),

          _PillInput(
            hint: 'Correo electrónico',
            icon: Icons.email_outlined,
            controller: _viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Requerido';
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(val.trim())) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 14),

          _PillInput(
            hint: 'Definir contraseña',
            icon: Icons.lock_outline,
            controller: _viewModel.passwordController,
            isPassword: true,
            validator: (val) {
              if (val == null || val.length < 8) return 'Mínimo 8 caracteres';
              if (!val.contains(RegExp(r'[A-Z]'))) return 'Debe tener al menos una mayúscula';
              if (!val.contains(RegExp(r'[a-z]'))) return 'Debe tener al menos una minúscula';
              if (!val.contains(RegExp(r'[0-9]'))) return 'Debe tener al menos un número';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // --- CHECKBOX REACTIVO ---
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _viewModel.dataConsent,
                      activeColor: AppColors.accent,
                      onChanged: (value) => _viewModel.setDataConsent(value ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Acepto la política de privacidad y el tratamiento de mis datos personales.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: AppColors.label,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // --- BOTÓN DE ENVÍO REACTIVO ---
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _handleRegisterSubmission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: _viewModel.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Crear mi cuenta', style: AppTextStyles.buttonPrimary),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

/// Selector tipo pestañas — INICIAR SESIÓN / REGISTRO. En esta pantalla,
/// "Registro" es la pestaña activa; "Iniciar sesión" navega al login.
class _AuthTabSwitcher extends StatelessWidget {
  final VoidCallback onTapLogin;

  const _AuthTabSwitcher({required this.onTapLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fillField,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              label: 'INICIAR SESIÓN',
              isActive: false,
              onTap: onTapLogin,
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'REGISTRO',
              isActive: true,
              onTap: null, // ya estamos en esta pantalla
            ),
          ),
        ],
      ),
    );
  }
}

/// Una "pastilla" individual dentro del [_AuthTabSwitcher].
class _TabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabPill({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: isActive ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

/// Campo tipo píldora/óvalo — ícono + placeholder dentro del mismo campo,
/// con soporte de validación (a diferencia del login, aquí se usa dentro
/// de un [Form]).
class _PillInput extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _PillInput({
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<_PillInput> createState() => _PillInputState();
}

class _PillInputState extends State<_PillInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: AppColors.muted, size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.muted,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : null,
        hintText: widget.hint,
        hintStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.muted,
        ),
        errorStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          color: AppColors.error,
        ),
        filled: true,
        fillColor: AppColors.fillField,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
    );
  }
}