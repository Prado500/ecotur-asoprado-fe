class TouristService {
  final String name;
  final String description;
  final String category;
  final double basePrice;
  final int maxCapacity;
  final bool isAvailable;
  final List<String> imageUrls; // La dejamos como lista de textos para que la UI la use fácil

  TouristService({
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.maxCapacity,
    required this.isAvailable,
    required this.imageUrls,
  });

  factory TouristService.fromJson(Map<String, dynamic> json) {
    // 1. Extraemos las URLs de la lista de OBJETOS que viene en "images"
    List<String> extractedUrls = [];
    if (json['images'] != null && json['images'] is List) {
      extractedUrls = (json['images'] as List)
          .map((img) => img['image_url'].toString())
          .toList();
    }

    return TouristService(
      name: json['name'] ?? 'Servicio sin nombre',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      // 2. Parseamos el precio que ahora sabemos que viene como String ("85000.00")
      basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
      maxCapacity: json['max_capacity'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      // 3. Le pasamos la lista limpia de textos que extrajimos arriba
      imageUrls: extractedUrls,
    );
  }

  // Helper para la portada principal del catálogo
  String get primaryImageUrl {
    return imageUrls.isNotEmpty ? imageUrls.first : '';
  }
}