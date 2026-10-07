import 'package:flutter/material.dart';
import '../../models/tourist_service_model.dart';
import '../../screens/details_screen.dart';
import '../../theme/app_text_style.dart';

class TouristCard extends StatelessWidget {
  final TouristService service;

  const TouristCard({super.key, required this.service});

  String _formatCurrency(double price) {
    final String stringPrice = price.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formatted = stringPrice.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return '\$$formatted COP';
  }

  @override
  Widget build(BuildContext context) {
    const orangeAccent = Color(0xFFDC6B3A);
    const blueTitle = Color(0xFF006875);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Image.network(
                  service.primaryImageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: const Color(0xFFE0E3E5),
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 36),
                  ),
                ),
                if (service.isAvailable)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CF8BB).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DESTACADO',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Color(0xFF00714D),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: blueTitle,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Color(0xFF5A6B6E),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Estado del paquete turístico y Precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: service.isAvailable
                                  ? const Color(0xFF006C49)
                                  : const Color(0xFF6B7A7D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service.isAvailable ? 'Disponible Hoy' : 'Próximamente',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              color: service.isAvailable
                                  ? const Color(0xFF006C49)
                                  : const Color(0xFF6B7A7D),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        _formatCurrency(service.basePrice),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: blueTitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(service: service),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Ver Detalles',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}