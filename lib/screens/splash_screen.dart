import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 3800);

  /// Controla la animación de carga del 0-100%
  late final AnimationController _progressController;

  /// Controla la órbita continua del avión alrededor del círculo.
  late final AnimationController _orbitController;

  bool _reduceMotion = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(vsync: this, duration: _totalDuration)
      ..addStatusListener(_onProgressStatusChanged);

    _orbitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    _progressController.forward();
    if (!_reduceMotion) {
      _orbitController.repeat();
    }
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo blanco, como en la referencia.
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          // Todo el contenido se agrupa y se centra como bloque único,
          // en lugar de repartirse con un Spacer.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OrbitingBrand(orbitController: _orbitController, reduceMotion: _reduceMotion),
              const SizedBox(height: 28),
              const Text(
                'ECOTUR ASOPRADO',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Explorando Prado-Tolima,\nun sendero a la vez',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.label,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              _ProgressIndicatorSection(controller: _progressController),
            ],
          ),
        ),
      ),
    );
  }
}

/// El círculo de marca (logo de la empresa) con el avión orbitando.
class _OrbitingBrand extends StatelessWidget {
  final AnimationController orbitController;
  final bool reduceMotion;

  const _OrbitingBrand({required this.orbitController, required this.reduceMotion});

  static const double _ringDiameter = 190;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ringDiameter,
      height: _ringDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo suave detrás del logo para que "flote" sobre el blanco.
          Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.06),
            ),
          ),

          // Logo circular de la empresa (imagen real).
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/asoprado_logo.jpeg',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Ruta de vuelo punteada.
          CustomPaint(
            size: const Size(_ringDiameter, _ringDiameter),
            painter: _DashedRingPainter(color: AppColors.accent.withOpacity(0.45)),
          ),

          // Avión orbitando — si el usuario pidió reducir movimiento,
          // se muestra fijo arriba en vez de rotar.
          reduceMotion
              ? const _OrbitPlane(angle: 0)
              : AnimatedBuilder(
            animation: orbitController,
            builder: (context, child) => _OrbitPlane(angle: orbitController.value * 2 * math.pi),
          ),
        ],
      ),
    );
  }
}

/// Posiciona el avión sobre el anillo según [angle], manteniéndolo
/// siempre "apuntando hacia adelante" en su recorrido (no gira sobre
/// sí mismo, solo se traslada).
class _OrbitPlane extends StatelessWidget {
  final double angle;

  const _OrbitPlane({required this.angle});

  @override
  Widget build(BuildContext context) {
    const radius = _OrbitingBrand._ringDiameter / 2;
    final dx = radius * math.cos(angle - math.pi / 2);
    final dy = radius * math.sin(angle - math.pi / 2);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 8),
          ],
        ),
        child: Transform.rotate(
          angle: angle + math.pi / 2, // el avión "mira" en la dirección de su recorrido
          child: const Icon(Icons.flight, color: AppColors.accent, size: 18),
        ),
      ),
    );
  }
}

/// Barra de progreso 0→100% + porcentaje en vivo.
class _ProgressIndicatorSection extends StatelessWidget {
  final AnimationController controller;

  const _ProgressIndicatorSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final percent = (controller.value * 100).clamp(0, 100).toInt();
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 140,
                height: 5,
                child: LinearProgressIndicator(
                  value: controller.value,
                  backgroundColor: AppColors.accent.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'CARGANDO... $percent%',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accentDark,
                letterSpacing: 0.2,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Anillo punteado — la "ruta de vuelo" sobre la que orbita el avión.
class _DashedRingPainter extends CustomPainter {
  final Color color;

  _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const dashCount = 36;
    const dashSweep = (2 * math.pi) / dashCount;
    const dashFraction = 0.55; // qué porción de cada segmento se dibuja (vs. espacio en blanco)

    for (int i = 0; i < dashCount; i++) {
      final start = i * dashSweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashSweep * dashFraction,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}