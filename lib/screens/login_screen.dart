import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../view_models/login_viewmodel.dart';
import '../utils/ui_helpers.dart';
import '../widgets/common/custom_input.dart';
import 'admin_dashboard_screen.dart';
import 'catalog_screen.dart';
import 'register_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

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
  /// Commands the ViewModel to perform the login and handles routing upon success.
  void _handleLoginSubmission() async {
    // The ViewModel processes the network transaction and session storage.
    // It returns the user role if successful, or null if it fails.
    final role = await _viewModel.performLogin();

    // Security check to prevent navigation on unmounted contexts
    if (!mounted) return;

    if (role != null) {
      // Route the user based on their specific role (RBAC)
      if (role == 'admin' || role == 'superadmin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CatalogScreen()));
      }
    }
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
/// Mobile Layout (Setup unicamente para dispositivos celulares con tarjeta blanca y campos tipo pildora)
  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.34;
    final logoSize = (screenHeight * 0.28).clamp(90.0, 130.0);

    return Stack(
      children: [
        Column(
          children: [
            // Cabecera Naranja
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
                      // Espacio reservado para que el logo circular no
                      // quede pegado al título al sobreponerse abajo.
                      SizedBox(height: (logoSize / 2) + 16),
                    ],
                  ),
                ),
              ),
            ),

            // Tarjeta blanca para form
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

        // Logo circular de la empresa
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

  /// Laptop Layout (Setup unicamente para dispositivos table o pc's con tarjeta blanca y campos tipo pildora)
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
                constraints: const BoxConstraints(maxWidth: 380),
                child: _buildFormBody(context, showWordmark: false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Form para móvil y escritorio. Los campos ahora
  /// Son tipo píldora ([_PillInput]) en ambos layouts.
  Widget _buildFormBody(BuildContext context, {bool showWordmark = true, Color? submitButtonColor}) {
    final buttonColor = submitButtonColor ?? AppColors.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showWordmark) ...[
          const Text('ECOTUR ASOPRADO', style: AppTextStyles.brandWordmark, textAlign: TextAlign.center),
          const SizedBox(height: 18),
        ],

        _AuthTabSwitcher(
          onTapRegister: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          ),
        ),
        const SizedBox(height: 24),

        Text.rich(
          TextSpan(
            style: AppTextStyles.displayTitle,
            children: [
              const TextSpan(text: '¡Bienvenido '),
              TextSpan(text: 'de nuevo!', style: AppTextStyles.displayTitle.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tus datos para continuar tu aventura.',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 28),

        _PillInput(
          hint: 'Correo electrónico',
          icon: Icons.email_outlined,
          controller: _viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _PillInput(
          hint: 'Contraseña',
          icon: Icons.lock_outline,
          controller: _viewModel.passwordController,
          isPassword: true,
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('¿Olvidaste tu contraseña?', style: AppTextStyles.link),
          ),
        ),
        const SizedBox(height: 18),

        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _viewModel.isLoading ? null : _handleLoginSubmission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: buttonColor.withOpacity(0.6),
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
                    Text('Iniciar sesión', style: AppTextStyles.buttonPrimary),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18, color: Colors.white)
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Campo tipo píldora para icono + placeholder dentro del mismo campo,
class _PillInput extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const _PillInput({
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_PillInput> createState() => _PillInputState();
}

class _PillInputState extends State<_PillInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
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
      ),
    );
  }
}
/// Selector tipo pestañas para apartados de Login & Registro.
class _AuthTabSwitcher extends StatelessWidget {
  final VoidCallback onTapRegister;

  const _AuthTabSwitcher({required this.onTapRegister});

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
              isActive: true,
              onTap: null,
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'REGISTRO',
              isActive: false,
              onTap: onTapRegister,
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