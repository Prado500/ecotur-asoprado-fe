import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import '../view_models/login_viewmodel.dart';
import '../view_models/register_viewmodel.dart';
import '../utils/ui_helpers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'admin_dashboard_screen.dart';
import 'catalog_screen.dart';
import 'password_screen.dart';

enum AuthMode { login, register }

/// Pantalla unificada de autenticación. La cabecera (logo) se
/// mantiene fija en pantalla; solo el formulario cambia entre login y
/// registro mediante un [AnimatedSwitcher].
class AuthScreen extends StatefulWidget {
  final AuthMode initialMode;
  final AuthService? authService;
  final SessionService? sessionService;
  final UserService? userService;

  const AuthScreen({
    super.key,
    this.initialMode = AuthMode.login,
    this.authService,
    this.sessionService,
    this.userService,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode;
  late final LoginViewModel _loginViewModel;
  late final RegisterViewModel _registerViewModel;
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;

    _loginViewModel = LoginViewModel(
      widget.authService ?? AuthService(),
      widget.sessionService ?? SessionService(),
    )..addListener(_onLoginViewModelChange);

    _registerViewModel = RegisterViewModel(widget.userService ?? UserService())
      ..addListener(_onRegisterViewModelChange);
  }

  void _onLoginViewModelChange() {
    if (_loginViewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _loginViewModel.errorMessage!, isError: true);
      _loginViewModel.clearError();
    }
  }

  void _onRegisterViewModelChange() {
    if (_registerViewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _registerViewModel.errorMessage!, isError: true);
      _registerViewModel.clearError();
    }
    if (_registerViewModel.isSuccess) {
      UIHelpers.showSnackBar(
        context,
        '¡Cuenta creada exitosamente! Revise su correo electrónico e inicie sesión.',
        isError: false,
      );
      setState(() => _mode = AuthMode.login);
    }
  }

  @override
  void dispose() {
    _loginViewModel.removeListener(_onLoginViewModelChange);
    _loginViewModel.dispose();
    _registerViewModel.removeListener(_onRegisterViewModelChange);
    _registerViewModel.dispose();
    super.dispose();
  }

  void _handleLoginSubmission() async {
    final role = await _loginViewModel.performLogin();
    if (!mounted) return;

    if (role != null) {
      final target = (role == 'admin' || role == 'superadmin')
          ? const AdminDashboardScreen()
          : const CatalogScreen();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => target));
    }
  }

  void _handlePassword() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordScreen()));
  }

  void _handleRegisterSubmission() {
    if (!_registerFormKey.currentState!.validate()) return;
    _registerViewModel.performRegister();
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
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

  /// Mobile screen: cabecera + logo FIJOS (no se reconstruyen al cambiar de modo)
  Widget _buildMobileLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.26;
    final logoSize = (size.width * 0.28).clamp(90.0, 130.0);

    return Stack(
      children: [
        Column(
          children: [
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
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -28),
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
                    child: _buildAnimatedFormBody(context),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                  'assets/images/asoprado_logo.jpeg',
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

  /// Desktop & Tablet Screen: imagen fija; a la derecha formulario
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
                child: _buildAnimatedFormBody(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Envuelve el formulario activo en un AnimatedSwitcher: al cambiar
  /// de modo, el contenido anterior se desvanece y el nuevo aparece con fade + leve deslizamiento, en vez de saltar abruptamente.
  Widget _buildAnimatedFormBody(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: _mode == AuthMode.login
          ? _buildLoginForm(context, key: const ValueKey('login'))
          : _buildRegisterForm(context, key: const ValueKey('register')),
    );
  }

  /// Campo con etiqueta + [_PillInput]. Centraliza el patrón
  /// "Text(label) + SizedBox + _PillInput" que antes se repetía en
  /// cada campo de ambos formularios.
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    double bottomSpacing = 14,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.brandWordmark),
          const SizedBox(height: 8),
          _PillInput(
            hint: hint,
            icon: icon,
            controller: controller,
            isPassword: isPassword,
            keyboardType: keyboardType,
            validator: validator,
          ),
        ],
      ),
    );
  }

  /// Formulario Login
  Widget _buildLoginForm(BuildContext context, {required Key key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuthTabSwitcher(mode: AuthMode.login, onModeSelected: _switchMode),
        const SizedBox(height: 24),

        const Text('Bienvenido de nuevo', style: AppTextStyles.displayTitle),
        const SizedBox(height: 8),
        const Text('Ingresa tus datos para acceder a tu cuenta.', style: AppTextStyles.subtitle),
        const SizedBox(height: 28),

        _buildField(
          label: 'CORREO ELECTRÓNICO',
          hint: 'correo@gmail.com',
          icon: Icons.email_outlined,
          controller: _loginViewModel.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildField(
          label: 'CONTRASEÑA',
          hint: '......',
          icon: Icons.lock_outline,
          controller: _loginViewModel.passwordController,
          isPassword: true,
          bottomSpacing: 8,
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handlePassword,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        ListenableBuilder(
          listenable: _loginViewModel,
          builder: (context, _) => _PrimaryButton(
            isLoading: _loginViewModel.isLoading,
            onPressed: _handleLoginSubmission,
            label: 'Iniciar sesión',
          ),
        ),
      ],
    );
  }

  /// Formulario de Registro.
  Widget _buildRegisterForm(BuildContext context, {required Key key}) {
    return Form(
      key: _registerFormKey,
      child: Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthTabSwitcher(mode: AuthMode.register, onModeSelected: _switchMode),
          const SizedBox(height: 24),
          const Text('Crea tu cuenta', style: AppTextStyles.displayTitle),
          const SizedBox(height: 14),
          const Text('Registrate para empezar a explorar Prado-Tolima', style: AppTextStyles.subtitle),
          const SizedBox(height: 28),

          _buildField(
            label: 'NOMBRE(S)',
            hint: 'Ej. Juan',
            icon: Icons.person_outline,
            controller: _registerViewModel.firstNameController,
            validator: _Validators.name,
          ),
          _buildField(
            label: 'APELLIDO(S)',
            hint: 'Ej. Pérez',
            icon: Icons.person_outline,
            controller: _registerViewModel.lastNameController,
            validator: _Validators.name,
          ),
          _buildField(
            label: 'CÉDULA DE CIUDADANÍA',
            hint: 'Ej. 1234567901',
            icon: Icons.badge_outlined,
            controller: _registerViewModel.cedulaController,
            keyboardType: TextInputType.number,
            validator: _Validators.cedula,
          ),
          _buildField(
            label: 'TELÉFONO',
            hint: 'Ej. 3115673216',
            icon: Icons.phone_outlined,
            controller: _registerViewModel.phoneController,
            keyboardType: TextInputType.phone,
            validator: _Validators.phone,
          ),
          _buildField(
            label: 'CORREO ELECTRÓNICO',
            hint: 'tu@gmail.com',
            icon: Icons.email_outlined,
            controller: _registerViewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _Validators.email,
          ),
          _buildField(
            label: 'CONTRASEÑA',
            hint: 'Crea una contraseña',
            icon: Icons.lock_outline,
            controller: _registerViewModel.passwordController,
            isPassword: true,
            validator: _Validators.password,
            bottomSpacing: 4,
          ),

          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: _registerViewModel,
            builder: (context, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _registerViewModel.dataConsent,
                      activeColor: AppColors.accent,
                      onChanged: (value) => _registerViewModel.setDataConsent(value ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Acepto la política de privacidad y el tratamiento de mis datos personales.',
                      style: TextStyle(fontFamily: AppTextStyles.fontFamily, color: AppColors.label, fontSize: 12),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          ListenableBuilder(
            listenable: _registerViewModel,
            builder: (context, _) => _PrimaryButton(
              isLoading: _registerViewModel.isLoading,
              onPressed: _handleRegisterSubmission,
              label: 'Crear mi cuenta',
            ),
          ),
        ],
      ),
    );
  }
}

/// Validadores para los campos de registro
class _Validators {
  static final _nameRegex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÜüÑñ]+(?:\s[A-Za-zÁÉÍÓÚáéíóúÜüÑñ]+)*$');
  static final _cedulaRegex = RegExp(r'^\d{6,10}$');
  static final _phoneRegex = RegExp(r'^3\d{9}$');
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? name(String? val) {
    if (val == null || val.trim().isEmpty) return 'Requerido';
    if (val.trim().length < 2) return 'Mínimo 2 letras';
    if (!_nameRegex.hasMatch(val.trim())) return 'Solo letras';
    return null;
  }

  static String? cedula(String? val) {
    if (val == null || val.trim().isEmpty) return 'Requerido';
    if (!_cedulaRegex.hasMatch(val.trim())) return 'Solo numérico (6 a 10 dígitos)';
    return null;
  }

  static String? phone(String? val) {
    if (val == null || val.trim().isEmpty) return 'Requerido';
    if (!_phoneRegex.hasMatch(val.trim())) return 'Debe iniciar con 3 y tener 10 dígitos';
    return null;
  }

  static String? email(String? val) {
    if (val == null || val.trim().isEmpty) return 'Requerido';
    if (!_emailRegex.hasMatch(val.trim())) return 'Correo inválido';
    return null;
  }

  static String? password(String? val) {
    if (val == null || val.length < 8) return 'Mínimo 8 caracteres';
    if (!val.contains(RegExp(r'[A-Z]'))) return 'Debe tener al menos una mayúscula';
    if (!val.contains(RegExp(r'[a-z]'))) return 'Debe tener al menos una minúscula';
    if (!val.contains(RegExp(r'[0-9]'))) return 'Debe tener al menos un número';
    return null;
  }
}

/// Botón principal con estado de carga.
class _PrimaryButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  const _PrimaryButton({required this.isLoading, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTextStyles.buttonPrimary),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
/// Selector tipo pestañas — comparte estado con la pantalla padre en [mode] indica
/// cuál pestaña pertenece a cada formulario.
class _AuthTabSwitcher extends StatelessWidget {
  final AuthMode mode;
  final ValueChanged<AuthMode> onModeSelected;

  const _AuthTabSwitcher({required this.mode, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fillField,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              label: 'INICIAR SESIÓN',
              isActive: mode == AuthMode.login,
              onTap: () => onModeSelected(AuthMode.login),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'REGISTRO',
              isActive: mode == AuthMode.register,
              onTap: () => onModeSelected(AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

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

/// Campo tipo píldora/óvalo — mismo componente visual.
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
      style: const TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 14, color: AppColors.textDark),
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
        hintStyle: const TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 14, color: AppColors.muted),
        errorStyle: const TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 11, color: AppColors.error),
        filled: true,
        fillColor: AppColors.fillField,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
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