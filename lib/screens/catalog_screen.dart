import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tourist_service_model.dart';
import 'details_screen.dart';
import 'profile_screen.dart';

class CatalogScreen extends StatefulWidget {
  // 1. Añadimos el parámetro opcional para inyectar el servicio
  final ApiService? apiService;

  const CatalogScreen({super.key, this.apiService});

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<TouristService>> futureServices;
  late final ApiService _apiService; // 2. Guardamos la instancia aquí

  @override
  void initState() {
    super.initState();
    // 3. Si nos pasaron un mock (desde el test), lo usamos.
    // Si no (desde la app normal), creamos uno real.
    _apiService = widget.apiService ?? ApiService();

    // 4. Usamos la variable local, no creamos uno nuevo
    futureServices = _apiService.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Fondo Base
      body: Stack(
        children: [
          // 1. EL PATRÓN DE FONDO (Network Pattern del HTML)
          Positioned.fill(
            child: CustomPaint(painter: GridPatternPainter()),
          ),

          // 2. CONTENIDO PRINCIPAL
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- APP BAR CUSTOMIZADO ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F6),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.menu, color: Color(0xFF00DAF3)),
                      ),
                      const Text(
                        'ECOTUR ASOPRADO',
                        style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF191C1E)),
                      ),
                      const SizedBox(width: 40), // Balance visual
                    ],
                  ),
                ),

                // --- HEADER DE LA SECCIÓN ---
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SERVICIOS TURÍSTICOS',
                        style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006875), letterSpacing: -0.5),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Explora nuestra selección de experiencias únicas y descubre la belleza natural y cultural de la región.',
                        style: TextStyle(color: Color(0xFF3B494C), fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),

                // --- EL CATÁLOGO (LISTA DE TARJETAS) ---
                Expanded(
                  child: FutureBuilder<List<TouristService>>(
                    future: futureServices,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF006875)));
                      } else if (snapshot.hasError) {
                        // Aquí se muestra el error amigable que armamos en ApiService
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Color(0xFFBA1A1A)),
                                const SizedBox(height: 16),
                                Text(
                                  snapshot.error.toString().replaceAll('Exception: ', ''),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF3B494C)),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  // Usamos la variable local aquí también por si el usuario le da "Reintentar"
                                  onPressed: () => setState(() => futureServices = _apiService.fetchServices()),
                                  child: const Text('Reintentar'),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Aún no hay paquetes disponibles.'));
                      }

                      List<TouristService> services = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return _buildTouristCard(service, context);
                        },
                      );
                    },
                  ),
                ),

                // Espacio para que el último elemento no quede detrás de la barra inferior
                const SizedBox(height: 80),
              ],
            ),
          ),

          // 3. BARRA DE NAVEGACIÓN INFERIOR (Bottom NavBar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 24, top: 12), // Safe Area padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.explore, 'Catálogo', isActive: true),
                  _buildNavItem(Icons.confirmation_number_outlined, 'Reservas'),
                  _buildNavItem(Icons.map_outlined, 'Mapa'),
                  _buildNavItem(Icons.person_outline, 'Perfil', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE LA TARJETA ---
  Widget _buildTouristCard(TouristService service, BuildContext context) {
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
          // Imagen de Cabecera
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
              // Etiqueta de Destacado (opcional)
              if (service.isAvailable)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6CF8BB).withOpacity(0.9), // Secondary Container
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('DESTACADO', style: TextStyle(color: Color(0xFF00714D), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
            ],
          ),

          // Contenido de la Tarjeta
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

                // Indicador de Estado
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

                // Botón Acción
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

  // --- ÍTEM DE LA BARRA INFERIOR ---
  Widget _buildNavItem(IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF006C49).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D)),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isActive ? const Color(0xFF006C49) : const Color(0xFF6B7A7D),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASE PARA EL PATRÓN DE FONDO ---
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006875).withOpacity(0.03) // Muy sutil
      ..strokeWidth = 1;

    const double spacing = 24.0;

    // Dibujar líneas verticales
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Dibujar líneas horizontales
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}