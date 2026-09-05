import 'package:ecotur_app/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import '../view_models/profile_viewmodel.dart';
import 'auth_screen.dart';

/// Dumb View rendering the user profile.
/// Delegates all session and data actions to the [ProfileViewModel].
class ProfileScreen extends StatefulWidget {
  final SessionService? sessionService;
  final UserService? userService;

  const ProfileScreen({super.key, this.sessionService, this.userService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Dependency Injection: Initialize the ViewModel with the Wide State service and Domain service
    _viewModel = ProfileViewModel(
      widget.sessionService ?? SessionService(),
      widget.userService ?? UserService(),
    );

    // Fire-and-forget invocation for future profile data hydration
    _viewModel.loadUserProfile();
  }

  @override
  void dispose() {
    // Release resources safely when the view is popped
    _viewModel.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    // Delegate the business logic to the ViewModel
    await _viewModel.performLogout();

    // Security check to prevent Context exceptions
    if (!mounted) return;

    // Purge the navigation stack and redirect to Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B494C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('MI PERFIL', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- USER CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF006875), width: 2)
                    ),
                    child: const Icon(Icons.person, size: 40, color: Color(0xFF006875)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Usuario del Sistema', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE0E3E5), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Configuración y Cuenta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B494C))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- LOGOUT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A)),
                label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}