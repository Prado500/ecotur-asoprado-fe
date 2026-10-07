import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_style.dart';
import '../../utils/responsive_helper.dart';
import '../../screens/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final String userInitials;
  final bool isAdmin;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.userInitials = 'U',
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    if (isDesktop) {
      return _buildDesktopTopBar(context);
    }
    return _buildMobileBottomBar(context);
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            children: [
              if (isAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
              ],
              _buildCompanyLogo(),
              const SizedBox(width: 12),
              Text(
                isAdmin ? 'CATÁLOGO PÚBLICO' : 'ECOTUR ASOPRADO',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF006875),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          if (!isAdmin)
            Row(
              children: [
                _buildDesktopNavItem(0, 'assets/images/experiencias.png', 'Experiencias'),
                const SizedBox(width: 16),
                _buildDesktopNavItem(1, 'assets/images/reserva.png', 'Reservas'),
                const SizedBox(width: 16),
                _buildDesktopNavItem(2, 'assets/images/mapa.png', 'Mapa'),
              ],
            ),

          InkWell(
            onTap: () {
              if (currentIndex != 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu, size: 18, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTextStyles.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem(int index, String assetPath, String label) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap?.call(index),
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: isSelected ? 1.0 : 0.6,
              child: Image.asset(
                assetPath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.category,
                  size: 20,
                  color: isSelected ? AppColors.accent : AppColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    final bool isProfileActive = currentIndex == 3;

    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMobileNavItem(
            context: context,
            assetPath: 'assets/images/experiencias.png',
            label: 'Experiencias',
            index: 0,
          ),
          _buildMobileNavItem(
            context: context,
            assetPath: 'assets/images/reserva.png',
            label: 'Reservas',
            index: 1,
          ),
          _buildMobileNavItem(
            context: context,
            assetPath: 'assets/images/mapa.png',
            label: 'Mapa',
            index: 2,
          ),
          _buildMobileNavItem(
            context: context,
            label: 'Perfil',
            index: 3,
            customIcon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isProfileActive ? AppColors.accent : AppColors.accent.withOpacity(0.8),
              ),
              alignment: Alignment.center,
              child: Text(
                userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
            ),
            customOnTap: () {
              if (currentIndex != 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem({
    required BuildContext context,
    String? assetPath,
    IconData? icon,
    Widget? customIcon,
    required String label,
    required int index,
    VoidCallback? customOnTap,
  }) {
    final bool isActive = currentIndex == index;

    Widget renderIcon() {
      if (customIcon != null) return customIcon;
      if (assetPath != null) {
        return Image.asset(
          assetPath,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.category,
            size: 22,
            color: isActive ? AppColors.accent : const Color(0xFF6B7A7D),
          ),
        );
      }
      return Icon(
        icon ?? Icons.circle,
        size: 22,
        color: isActive ? AppColors.accent : const Color(0xFF6B7A7D),
      );
    }

    return GestureDetector(
      onTap: customOnTap ?? () => onTap?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border(
                top: BorderSide(
                  color: isActive ? AppColors.accent : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: renderIcon(),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.bottomNavLabel.copyWith(
              color: isActive ? AppColors.accent : const Color(0xFF6B7A7D),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo() {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(shape: BoxShape.circle),
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
}