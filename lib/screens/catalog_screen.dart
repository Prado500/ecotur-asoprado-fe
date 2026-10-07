import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import '../view_models/catalog_viewmodel.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import '../widgets/catalog/tourist_card.dart';
import '../utils/responsive_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

/// Dumb View representing the tourist catalog.
/// Dynamically adjusts its entire layout (AppBar and BottomNav) based on the user's authenticated role
/// to preserve hierarchical navigation flows for Administrators.
class CatalogScreen extends StatefulWidget {
  final CatalogService? catalogService;
  final SessionService? sessionService;
  final UserService? userService;

  const CatalogScreen({
    super.key,
    this.catalogService,
    this.sessionService,
    this.userService,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogViewModel _viewModel;
  late final SessionService _sessionService;
  late final UserService _userService;

  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _userName;

  @override
  void initState() {
    super.initState();
    final service = widget.catalogService ?? CatalogService();
    _sessionService = widget.sessionService ?? SessionService();
    _userService = widget.userService ?? UserService();
    _viewModel = CatalogViewModel(service);

    _sessionService.checkExistingSession();
    _viewModel.loadCatalog();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _userService.fetchMyProfile();
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final firstName = data['first_name'] ?? data['nombre'] ?? '';
        final lastName = data['last_name'] ?? data['apellido'] ?? '';

        if (mounted) {
          setState(() {
            _userName = '$firstName $lastName'.trim();
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar datos del usuario en CatalogScreen: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _getUserInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'U';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _sessionService,
      builder: (context, _) {
        final isAdmin = _sessionService.userRole == 'admin' || _sessionService.userRole == 'superadmin';
        final isDesktop = ResponsiveHelper.isDesktop(context);

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                if (isDesktop)
                  CustomBottomNavBar(
                    currentIndex: _selectedNavIndex,
                    userInitials: _getUserInitials(_userName),
                    isAdmin: isAdmin,
                    onTap: (index) {
                      setState(() {
                        _selectedNavIndex = index;
                      });
                    },
                  )

                else
                  _buildMobileHeader(isAdmin),


                Expanded(
                  child: _buildBodyContent(isDesktop),
                ),
              ],
            ),
          ),

          bottomNavigationBar: (!isAdmin && !isDesktop)
              ? CustomBottomNavBar(
            currentIndex: _selectedNavIndex,
            userInitials: _getUserInitials(_userName),
            isAdmin: isAdmin,
            onTap: (index) {
              setState(() {
                _selectedNavIndex = index;
              });
            },
          )
              : null,
        );
      },
    );
  }

  Widget _buildBodyContent(bool isDesktop) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildExperiencesTab(isDesktop);
      case 1:
        return _buildReservationsTab();
      case 2:
        return _buildMapTab();
      default:
        return _buildExperiencesTab(isDesktop);
    }
  }

  Widget _buildExperiencesTab(bool isDesktop) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 48 : 24,
            20,
            isDesktop ? 48 : 24,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'SERVICIOS TURÍSTICOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF006875),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Explora nuestra selección de experiencias únicas y descubre la belleza natural y cultural de la región.',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 20),
              Center(
                child: _buildSearchBar(isDesktop),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              if (_viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              if (_viewModel.errorMessage != null) {
                return _buildErrorState(_viewModel.errorMessage!);
              }

              final filteredServices = _viewModel.services.where((service) {
                final query = _searchQuery.toLowerCase().trim();
                if (query.isEmpty) return true;
                final nameMatch = service.name.toLowerCase().contains(query);
                final descMatch = service.description.toLowerCase().contains(query);
                return nameMatch || descMatch;
              }).toList();

              if (filteredServices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Aún no hay paquetes disponibles.'
                            : 'No se encontraron resultados para "$_searchQuery"',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                );
              }

              return isDesktop
                  ? GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisExtent: 360,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  return TouristCard(service: filteredServices[index]);
                },
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TouristCard(service: filteredServices[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReservationsTab() {
    return const Center(
      child: Text(
        'Sección de Reservas',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006875)),
      ),
    );
  }

  Widget _buildMapTab() {
    return const Center(
      child: Text(
        'Sección de Mapa Interactivo',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006875)),
      ),
    );
  }

  Widget _buildSearchBar(bool isDesktop) {
    return Container(
      width: isDesktop ? 520 : double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar paquete turístico',
          hintStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13.5,
            color: AppColors.muted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF006875),
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: AppColors.muted),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : Container(
            margin: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent,
            ),
            child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMobileHeader(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            _buildCompanyLogo(size: 36),
          const SizedBox(width: 12),
          Text(
            isAdmin ? 'CATÁLOGO PÚBLICO' : 'ECOTUR ASOPRADO',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF006875),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/asoprado_logo.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.explore, color: AppColors.accent, size: 20),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(errorText, textAlign: TextAlign.center, style: AppTextStyles.subtitle),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _viewModel.loadCatalog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: const StadiumBorder(),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}