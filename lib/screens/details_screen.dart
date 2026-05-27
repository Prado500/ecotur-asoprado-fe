import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tourist_service_model.dart';

class DetailsScreen extends StatefulWidget {
  final TouristService service;

  const DetailsScreen({super.key, required this.service});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // 2. Usamos el nuevo nombre de la lista: imageUrls
    if (widget.service.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  // --- LÓGICA DEL SLIDE DECK ---
  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      int nextIndex = _currentIndex + 1;
      // Usamos el nuevo nombre: imageUrls
      if (nextIndex >= widget.service.imageUrls.length) {
        nextIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onUserInteraction(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
    _timer?.cancel();
    if (widget.service.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Fondo del Design System

      // --- APP BAR TRANSPARENTE ---
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
            // --- EL CONTENEDOR DEL SLIDE DECK ---
            SizedBox(
              height: 350, // Un poco más alto para verse más premium
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Las imágenes deslizables
                  PageView.builder(
                    controller: _pageController,
                    // Usamos el nuevo nombre: imageUrls
                    itemCount: widget.service.imageUrls.isEmpty ? 1 : widget.service.imageUrls.length,
                    onPageChanged: _onUserInteraction,
                    itemBuilder: (context, index) {
                      // Si no hay imágenes, mostramos un placeholder
                      if (widget.service.imageUrls.isEmpty) {
                        return Container(
                          color: const Color(0xFFE0E3E5),
                          child: const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
                        );
                      }

                      return Image.network(
                        widget.service.imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE0E3E5),
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                        ),
                      );
                    },
                  ),

                  // Gradiente inferior para que los puntitos y la foto se vean bien
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Los Indicadores (Puntitos)
                  if (widget.service.imageUrls.length > 1)
                    Positioned(
                      bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.service.imageUrls.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 24 : 8, // Pill shape para el activo
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentIndex == index ? const Color(0xFF6CF8BB) : Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),

            // --- LA INFORMACIÓN DEL PAQUETE ---
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0), // Sube el contenedor un poco sobre la imagen
              decoration: const BoxDecoration(
                color: Color(0xFFF7F9FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría y Estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.service.category.toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006875), letterSpacing: 1.0),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                  color: widget.service.isAvailable ? const Color(0xFF006C49) : const Color(0xFF6B7A7D),
                                  shape: BoxShape.circle
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.service.isAvailable ? 'Disponible Hoy' : 'Próximamente',
                              style: TextStyle(
                                color: widget.service.isAvailable ? const Color(0xFF006C49) : const Color(0xFF6B7A7D),
                                fontSize: 12, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Título
                    Text(
                      widget.service.name,
                      style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF191C1E), height: 1.1),
                    ),
                    const SizedBox(height: 16),

                    // Precio y Capacidad
                    Row(
                      children: [
                        Text(
                          '\$${widget.service.basePrice.toStringAsFixed(0)} COP',
                          style: const TextStyle(fontSize: 24, color: Color(0xFF006875), fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        const Icon(Icons.group_outlined, color: Color(0xFF6B7A7D), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Máx ${widget.service.maxCapacity} pers.',
                          style: const TextStyle(color: Color(0xFF6B7A7D), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),

                    // Descripción
                    const Text(
                      'Acerca del recorrido',
                      style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.service.description,
                      style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF3B494C)),
                    ),

                    // Espacio inferior para el botón
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BOTÓN FLOTANTE INFERIOR ---
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
              onPressed: widget.service.isAvailable ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006875),
                disabledBackgroundColor: const Color(0xFFE0E3E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                  widget.service.isAvailable ? 'Reservar Ahora' : 'No Disponible',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)
              ),
            ),
          ),
        ),
      ),
    );
  }
}