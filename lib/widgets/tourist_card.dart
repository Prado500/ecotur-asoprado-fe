import 'package:flutter/material.dart';
import '../models/tourist_service_model.dart';
import '../screens/details_screen.dart';

class TouristCard extends StatelessWidget {
  final TouristService service;

  const TouristCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: Image.network(
                  service.primaryImageUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 190,
                    color: const Color(0xFFE0E3E5),
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                  ),
                ),
              ),
              if (service.isAvailable)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6CF8BB).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('DESTACADO', style: TextStyle(color: Color(0xFF00714D), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF3B494C), fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: service.isAvailable ? const Color(0xFF006C49) : const Color(0xFF6B7A7D),
                          shape: BoxShape.circle
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.isAvailable ? 'Disponible Hoy' : 'Próximamente',
                      style: TextStyle(
                        color: service.isAvailable ? const Color(0xFF006C49) : const Color(0xFF6B7A7D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailsScreen(service: service)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: service.isAvailable ? const Color(0xFF006875) : Colors.white,
                      foregroundColor: service.isAvailable ? Colors.white : const Color(0xFF191C1E),
                      elevation: 0,
                      side: service.isAvailable ? BorderSide.none : const BorderSide(color: Color(0xFFBAC9CC)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ver Detalles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}