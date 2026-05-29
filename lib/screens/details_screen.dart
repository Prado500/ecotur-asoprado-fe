import 'package:flutter/material.dart';
import '../models/tourist_service_model.dart';
import '../widgets/catalog/image_carousel.dart';

class DetailsScreen extends StatelessWidget {
  final TouristService service;

  const DetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF191C1E)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El componente extraído
            ImageCarousel(imageUrls: service.imageUrls),

            // La información
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F9FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service.category.toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006875), letterSpacing: 1.0),
                        ),
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
                                fontSize: 12, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      service.name,
                      style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF191C1E), height: 1.1),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '\$${service.basePrice.toStringAsFixed(0)} COP',
                          style: const TextStyle(fontSize: 24, color: Color(0xFF006875), fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        const Icon(Icons.group_outlined, color: Color(0xFF6B7A7D), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Máx ${service.maxCapacity} pers.',
                          style: const TextStyle(color: Color(0xFF6B7A7D), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                    const Text(
                      'Acerca del recorrido',
                      style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      service.description,
                      style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF3B494C)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: service.isAvailable ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006875),
                disabledBackgroundColor: const Color(0xFFE0E3E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                  service.isAvailable ? 'Reservar Ahora' : 'No Disponible',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)
              ),
            ),
          ),
        ),
      ),
    );
  }
}