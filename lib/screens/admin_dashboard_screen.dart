import 'package:flutter/material.dart';
import '../services/tourist_service.dart';
import '../widgets/admin/admin_bottom_nav_bar.dart';
import '../view_models/admin_dashboard_viewmodel.dart';
import '../utils/ui_helpers.dart';
import 'profile_screen.dart';

/// Dumb View rendering the Administrative Action Hub.
/// Incorporates high-performance entry animations and observes [AdminDashboardViewModel].
class AdminDashboardScreen extends StatefulWidget {
  final TouristService? touristService;

  const AdminDashboardScreen({super.key, this.touristService});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final AdminDashboardViewModel _viewModel;
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Dependency Injection
    _viewModel = AdminDashboardViewModel(widget.touristService ?? TouristService());
    _viewModel.addListener(_onViewModelChange);

    // Hardware-accelerated animation configuration (Slide-In)
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    // Trigger sequential loading: Fetch profile, then animate UI
    _initializeHub();
  }

  Future<void> _initializeHub() async {
    await _viewModel.loadAdminProfile();
    if (mounted) {
      _animController.forward();
    }
  }

  void _onViewModelChange() {
    if (_viewModel.errorMessage != null) {
      UIHelpers.showSnackBar(context, _viewModel.errorMessage!, isError: true);
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  /// Builds the centralized action cards following the specific Paint mockup design.
  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF006875), width: 2), // Corporate primary border
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF006875)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Right Version Indicator
            const Positioned(
              top: 24, right: 32,
              child: Text('V 0.2.0', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B494C))),
            ),

            Center(
              child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, child) {
                    if (_viewModel.isLoading) {
                      return const CircularProgressIndicator(color: Color(0xFF006875));
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. Glowing Greeting Effect ONLY on the name using RichText
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF191C1E),
                                ),
                                children: [
                                  const TextSpan(text: 'HOLA '),
                                  TextSpan(
                                    text: '${_viewModel.firstName.toUpperCase()}',
                                    style: TextStyle(
                                      shadows: [
                                        Shadow(
                                            color: const Color(0xFF00DAF3).withValues(alpha: value),
                                            blurRadius: 20 * value
                                        ),
                                      ],
                                    ),
                                  ),
                                   const TextSpan(
                                    text: ','
                                  )
                                ],
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        // 2. Slide-In Subtitle (Implicitly inherits the Inter font)
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _animController,
                            child: const Text(
                              '¿Qué haremos hoy?',
                              style: TextStyle(fontSize: 18, color: Color(0xFF3B494C), fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),

                        // 3. Centralized Action Grid
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            _buildActionCard('Administrar\npaquetes', Icons.inventory_2_outlined, () {
                              // TODO: Navigate to Kanban Screen
                            }),
                            _buildActionCard('Administrar\nusuarios', Icons.people_outline, () {
                              // TODO: Navigate to User Management
                            }),
                            _buildActionCard('Opciones\nAdicionales', Icons.settings_outlined, () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                            }),
                          ],
                        ),
                      ],
                    );
                  }
              ),
            ),

            // Bottom Navigation Bar
            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: AdminBottomNavBar(currentIndex: 0),
            ),
          ],
        ),
      ),
    );
  }
}